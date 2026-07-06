import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // keep old showSnack import
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifier = TextEditingController();
  final _token = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _requesting = false;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void dispose() {
    _resendTimer?.cancel();
    _identifier.dispose();
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    if (_requesting || _resendSeconds > 0) return;
    setState(() {
      _fieldErrors = {};
      _requesting = true;
    });
    try {
      final identifier = _identifier.text.trim();
      await ref.read(authControllerProvider.notifier).forgotPassword(identifier);
      if (mounted) {
        setState(() {
          _requesting = false;
          _resendSeconds = 40;
        });
        _resendTimer?.cancel();
        _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            if (_resendSeconds > 0) {
              _resendSeconds--;
            } else {
              timer.cancel();
            }
          });
        });
        final isEmail = identifier.contains('@');
        showSnack(context, isEmail ? 'Password reset link sent to your email.' : 'Password reset OTP sent to your WhatsApp.');
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _requesting = false);
        if (failure.errors is Map<String, dynamic>) {
          setState(() {
            _fieldErrors = failure.errors as Map<String, dynamic>;
          });
        }
        showSnack(context, failure.message);
      }
    }
  }

  Future<void> _reset() async {
    setState(() => _fieldErrors = {});
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(_identifier.text.trim(), _token.text.trim(), _password.text);
      if (mounted) {
        showSnack(context, 'Password reset successfully. You can now login.');
        final state = GoRouterState.of(context);
        final redirectTo = state.uri.queryParameters['redirect_to'];
        if (redirectTo != null) {
          context.go('/login?redirect_to=${Uri.encodeComponent(redirectTo)}');
        } else {
          context.go('/login');
        }
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        if (failure.errors is Map<String, dynamic>) {
          setState(() {
            _fieldErrors = failure.errors as Map<String, dynamic>;
          });
        }
        showSnack(context, failure.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Recovery',
      subtitle: 'Reset your password securely',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF140C2C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your registered email address or mobile number. We will send you a reset link or OTP to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Email Address or Mobile Number',
            hint: 'john.doe@example.com or 9999999999',
            controller: _identifier,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.account_circle_outlined,
            errorText: _fieldErrors['identifier'] is List ? _fieldErrors['identifier'][0] : (_fieldErrors['identifier'] ?? _fieldErrors['email'])?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requesting || _resendSeconds > 0 ? null : _request,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF917CFF),
              foregroundColor: const Color(0xFF140C2C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _requesting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF140C2C), strokeWidth: 2))
                : Text(
                    _resendSeconds > 0 ? 'Resend in ${_resendSeconds}s' : 'Send Reset Link or OTP',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Already have a token or OTP? Enter it below with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'Reset Token or OTP',
            hint: 'Enter the token or OTP',
            controller: _token,
            suffixIcon: Icons.vpn_key_outlined,
            errorText: _fieldErrors['token'] is List ? _fieldErrors['token'][0] : _fieldErrors['token']?.toString(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'New Password',
            hint: '********',
            controller: _password,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            errorText: _fieldErrors['new_password'] is List ? _fieldErrors['new_password'][0] : (_fieldErrors['new_password'] ?? _fieldErrors['password'])?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF917CFF),
              foregroundColor: const Color(0xFF140C2C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              final state = GoRouterState.of(context);
              final redirectTo = state.uri.queryParameters['redirect_to'];
              if (redirectTo != null) {
                context.go('/login?redirect_to=${Uri.encodeComponent(redirectTo)}');
              } else {
                context.go('/login');
              }
            },
            child: const Text('Back to Sign In', style: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
