import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String identifier;
  const ResetPasswordScreen({super.key, required this.identifier});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _requesting = false;
  Map<String, dynamic> _fieldErrors = {};
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_requesting) return;
    setState(() {
      _fieldErrors = {};
    });

    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _fieldErrors = {
          if (otp.isEmpty) 'otp': 'OTP is required.',
          if (password.isEmpty) 'password': 'Password is required.',
          if (confirmPassword.isEmpty) 'confirm': 'Confirm Password is required.',
        };
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _fieldErrors = {'confirm': 'Passwords do not match.'};
      });
      return;
    }

    setState(() {
      _requesting = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(widget.identifier, otp, password);
      if (mounted) {
        setState(() => _requesting = false);
        showSnack(context, 'Password reset successfully! Please login.');
        context.go('/login');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthLayout(
      title: 'Reset Password',
      subtitle: 'Enter your OTP and new password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'An OTP has been sent to ${widget.identifier}. Enter it below to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'OTP Code',
            hint: 'Enter 6-digit OTP',
            controller: _otpController,
            keyboardType: TextInputType.number,
            suffixIcon: Icons.lock_clock_outlined,
            errorText: _fieldErrors['token'] is List ? _fieldErrors['token'][0] : _fieldErrors['otp']?.toString(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'New Password',
            hint: 'Enter your new password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            errorText: _fieldErrors['new_password'] is List ? _fieldErrors['new_password'][0] : _fieldErrors['password']?.toString(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your new password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffixIcon: _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            errorText: _fieldErrors['confirm']?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requesting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _requesting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text('Back to Login', style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
