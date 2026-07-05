import 'dart:async';

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
    this.user,
    this.error,
    this.fieldErrors,
  });

  const AuthState.loading() : this(isLoading: true, isAuthenticated: false);

  const AuthState.signedOut([String? error, Map<String, dynamic>? fieldErrors])
    : this(isLoading: false, isAuthenticated: false, error: error, fieldErrors: fieldErrors);

  const AuthState.signedIn({AuthUser? user})
    : this(isLoading: false, isAuthenticated: true, user: user);

  final bool isLoading;
  final bool isAuthenticated;
  final AuthUser? user;
  final String? error;
  final Map<String, dynamic>? fieldErrors;
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  StudentApi get _api => ref.read(studentApiProvider);

  @override
  AuthState build() {
    Future.microtask(_bootstrap);
    return const AuthState.loading();
  }

  Future<void> _bootstrap() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    state = tokens?.isComplete ?? false
        ? const AuthState.signedIn()
        : const AuthState.signedOut();
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

  Future<bool> register(Map<String, dynamic> payload) {
    return _completeLogin(() => _api.register(payload));
  }

  Future<void> checkAvailability({String? email, String? mobile}) =>
      _api.checkAvailability(email: email, mobile: mobile);

  Future<void> sendOtp(String mobile) => _api.sendOtp(mobile);
  
  Future<void> sendRegisterOtp(String mobile) => _api.sendRegisterOtp(mobile);

  Future<void> forgotPassword(String identifier) => _api.forgotPassword(identifier);

  Future<void> resetPassword(String identifier, String token, String password) =>
      _api.resetPassword(identifier, token, password);

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Local logout must still complete if the server is unavailable.
    }
    await ref.read(tokenStoreProvider).clear();
    state = const AuthState.signedOut();
  }

  Future<bool> _completeLogin(Future<LoginResult> Function() action) async {
    state = const AuthState.loading();
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
      final fieldErrors = failure.errors is Map ? failure.errors as Map<String, dynamic> : null;
      state = AuthState.signedOut(failure.message, fieldErrors);
      return false;
    } catch (error) {
      state = AuthState.signedOut(error.toString());
      return false;
    }
  }
}
