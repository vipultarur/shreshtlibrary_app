import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';

class VerifyResetOtpScreen extends ConsumerStatefulWidget {
  final String identifier;
  const VerifyResetOtpScreen({super.key, required this.identifier});

  @override
  ConsumerState<VerifyResetOtpScreen> createState() =>
      _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends ConsumerState<VerifyResetOtpScreen> {
  final _otpController = TextEditingController();
  bool _requesting = false;
  Map<String, dynamic> _fieldErrors = {};

  // 45-second OTP countdown timer
  Timer? _otpTimer;
  int _secondsRemaining = 45;
  bool _otpExpired = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _secondsRemaining = 45;
      _otpExpired = false;
    });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _secondsRemaining = 0;
            _otpExpired = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_resending) return;
    setState(() => _resending = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(widget.identifier);
      if (mounted) {
        setState(() => _resending = false);
        _startOtpTimer();
        AppSnackbar.show(context, message: 'New OTP sent to ${widget.identifier}', type: AppSnackbarType.success);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _resending = false);
        AppSnackbar.show(context, message: failure.message, type: AppSnackbarType.error);
      }
    }
  }

  Future<void> _submit() async {
    if (_requesting) return;
    setState(() {
      _fieldErrors = {};
    });

    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _fieldErrors = {'otp': 'OTP is required.'};
      });
      return;
    }

    if (_otpExpired) {
      setState(() {
        _fieldErrors = {'otp': 'OTP has expired. Please request a new one.'};
      });
      return;
    }

    setState(() {
      _requesting = true;
    });

    try {
      // Verify OTP
      await ref
          .read(authControllerProvider.notifier)
          .verifyForgotPasswordOtp(widget.identifier, otp);
      if (mounted) {
        setState(() => _requesting = false);
        // OTP verified successfully, proceed to reset password screen
        context.push(
          '/reset-password?identifier=${Uri.encodeComponent(widget.identifier)}&token=${Uri.encodeComponent(otp)}',
        );
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _requesting = false);
        if (failure.errors is Map<String, dynamic>) {
          setState(() {
            _fieldErrors = failure.errors as Map<String, dynamic>;
          });
        }
        AppSnackbar.show(context, message: failure.message, type: AppSnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthLayout(
      title: 'Verify OTP',
      subtitle: 'Enter the OTP sent to your email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify OTP',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'An OTP has been sent to ${widget.identifier}. Enter it below to proceed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),

          // OTP Countdown Timer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: _otpExpired
                  ? Colors.red.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _otpExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
                  size: 18,
                  color: _otpExpired ? Colors.red : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _otpExpired
                      ? 'OTP expired'
                      : 'OTP expires in ${_secondsRemaining}s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _otpExpired ? Colors.red : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AuthTextField(
            label: 'OTP Code',
            hint: 'Enter 6-digit OTP',
            controller: _otpController,
            keyboardType: TextInputType.number,
            suffixIcon: Icons.lock_clock_outlined,
            errorText: _fieldErrors['token'] is List
                ? _fieldErrors['token'][0]
                : _fieldErrors['otp']?.toString(),
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
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
          ),
          const SizedBox(height: 16),

          // Resend OTP button (visible when expired)
          if (_otpExpired)
            ElevatedButton.icon(
              onPressed: _resending ? null : _resendOtp,
              icon: _resending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_resending ? 'Sending...' : 'Resend OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
