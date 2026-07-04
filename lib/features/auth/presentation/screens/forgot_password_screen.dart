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
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    setState(() => _fieldErrors = {});
    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(_email.text.trim());
      if (mounted) showSnack(context, 'Password reset request sent. Please check your email.');
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

  Future<void> _reset() async {
    setState(() => _fieldErrors = {});
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(_token.text.trim(), _password.text);
      if (mounted) {
        showSnack(context, 'Password reset successfully. You can now login.');
        context.go('/login');
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
            'Enter your registered email address. We will send you a token to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Email Address',
            hint: 'john.doe@example.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.email_outlined,
            errorText: _fieldErrors['email'] is List ? _fieldErrors['email'][0] : _fieldErrors['email']?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _request,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF140C2C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            'Already have a token? Enter it below with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'Reset Token',
            hint: 'Enter the token',
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
            errorText: _fieldErrors['password'] is List ? _fieldErrors['password'][0] : _fieldErrors['password']?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C1B54),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Sign In', style: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
