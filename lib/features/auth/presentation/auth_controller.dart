import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/student_api.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.isMaintenance = false,
    this.user,
    this.error,
    this.fieldErrors,
  });

  const AuthState.loading() : this(isLoading: true, isAuthenticated: false);

  const AuthState.maintenance()
    : this(isLoading: false, isAuthenticated: false, isMaintenance: true);

  const AuthState.signedOut([String? error, Map<String, dynamic>? fieldErrors])
    : this(
        isLoading: false,
        isAuthenticated: false,
        error: error,
        fieldErrors: fieldErrors,
      );

  const AuthState.signedIn({AuthUser? user})
    : this(isLoading: false, isAuthenticated: true, user: user);

  final bool isLoading;
  final bool isAuthenticated;
  final bool isMaintenance;
  final AuthUser? user;
  final String? error;
  final Map<String, dynamic>? fieldErrors;
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  StudentApi get _api => ref.read(studentApiProvider);

  Timer? _pollingTimer;

  @override
  AuthState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    Future.microtask(_bootstrap);
    return const AuthState.loading();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(minutes: 5), // Increased from 15 seconds to reduce API calls
      (_) => _pollStatus(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _pollStatus() async {
    try {
      final info = await _api.libraryInfo();
      if (info.maintenanceMode) {
        if (!state.isMaintenance) {
          state = const AuthState.maintenance();
          _stopPolling();
        }
        return;
      } else if (state.isMaintenance) {
        // Recover from maintenance
        _bootstrap();
        return;
      }

      if (state.isAuthenticated) {
        // Trigger a background refresh of the dashboard
        ref.invalidate(dashboardProvider);
      }
    } catch (_) {
      // Ignore network errors during polling
    }
  }

  Future<void> _bootstrap() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    final isSignedIn = tokens?.isComplete ?? false;

    state = isSignedIn
        ? const AuthState.signedIn()
        : const AuthState.signedOut();

    if (isSignedIn) {
      // Always refresh the FCM token with the backend on startup,
      // because the OS may have issued a new token since last login.
      _registerFcmToken();

      // Listen for future token rotations (OS can refresh the token any time)
      FirebaseMessaging.instance.onTokenRefresh.listen(_registerFcmTokenValue);
    }

    _startPolling();
    
    // We don't call _pollStatus() here anymore because the UI (e.g. HomeScreen)
    // will watch dashboardProvider and trigger a fetch automatically.
    // This prevents redundant API calls on startup.
  }

  void _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('[FCM] Registering token with backend...');
        await _api.registerDeviceToken(token);
        debugPrint('[FCM] ✅ Token registered successfully!');
      }
    } catch (e) {
      debugPrint('[FCM] ❌ Token registration failed: $e');
    }
  }

  void _registerFcmTokenValue(String token) async {
    try {
      await _api.registerDeviceToken(token);
    } catch (_) {}
  }

  Future<bool> loginEmail(String email, String password) {
    return _completeLogin(() => _api.loginEmail(email, password));
  }

  Future<bool> loginMobile(String mobile, String password) {
    return _completeLogin(() => _api.loginMobile(mobile, password));
  }

  Future<bool> verifyOtp(String mobile, String otp) {
    return _completeLogin(() => _api.verifyOtp(mobile, otp));
  }

  Future<void> verifyRegisterOtp(String mobile, String otp) =>
      _api.verifyRegisterOtp(mobile, otp);

  Future<bool> register(Map<String, dynamic> payload) {
    return _completeLogin(() => _api.register(payload));
  }

  Future<bool> checkAvailability({String? email, String? mobile}) =>
      _api.checkAvailability(email: email, mobile: mobile);

  Future<void> sendOtp(String mobile) => _api.sendOtp(mobile);

  Future<void> sendRegisterOtp(String mobile) => _api.sendRegisterOtp(mobile);

  Future<void> forgotPassword(String identifier) =>
      _api.forgotPassword(identifier);

  Future<void> verifyForgotPasswordOtp(String identifier, String token) =>
      _api.verifyForgotPasswordOtp(identifier, token);

  Future<void> resetPassword(
    String identifier,
    String token,
    String password,
  ) => _api.resetPassword(identifier, token, password);

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Local logout must still complete if the server is unavailable.
    }

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Ignore FCM errors during logout
    }

    await ref.read(tokenStoreProvider).clear();
    state = const AuthState.signedOut();
  }

  Future<bool> _completeLogin(Future<LoginResult> Function() action) async {
    try {
      final result = await action();
      await ref.read(tokenStoreProvider).save(result.tokens);
      state = AuthState.signedIn(user: result.user);

      // Register FCM token after successful login
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _api.registerDeviceToken(token);
        }
      } catch (_) {
        // Ignore FCM errors during login
      }

      return true;
    } on ApiFailure catch (failure) {
      final fieldErrors = failure.errors is Map
          ? failure.errors as Map<String, dynamic>
          : null;
      state = AuthState.signedOut(failure.message, fieldErrors);
      return false;
    } catch (error) {
      state = AuthState.signedOut(error.toString());
      return false;
    }
  }
}
