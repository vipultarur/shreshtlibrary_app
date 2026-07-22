import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // keep old showSnack import
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifier = TextEditingController();
  bool _requesting = false;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _whatsappEnabled = true;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    try {
      final info = await ref.read(studentApiProvider).libraryInfo();
      if (mounted) {
        setState(() {
          _whatsappEnabled = info.enableWhatsappService;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    if (_requesting) return;
    setState(() {
      _fieldErrors = {};
      _requesting = true;
    });

    final identifier = _identifier.text.trim();

    if (!_whatsappEnabled) {
      final isNumber = RegExp(r'^[0-9]+$').hasMatch(identifier);
      if (isNumber) {
        setState(() {
          _fieldErrors = {
            'identifier':
                'WhatsApp is disabled. Please enter your email address.',
          };
          _requesting = false;
        });
        return;
      }
      if (!identifier.contains('@') || !identifier.contains('.')) {
        setState(() {
          _fieldErrors = {
            'identifier':
                'Please enter a valid email address (e.g. student@gmail.com).',
          };
          _requesting = false;
        });
        return;
      }
    } else {
      // WhatsApp enabled: must be either email or 10-digit number
      final isEmail = identifier.contains('@');
      final isMobile = RegExp(r'^[0-9]{10,}$').hasMatch(identifier);
      if (!isEmail && !isMobile) {
        setState(() {
          _fieldErrors = {
            'identifier': 'Enter a valid email or mobile number.',
          };
          _requesting = false;
        });
        return;
      }
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(identifier);
      if (mounted) {
        setState(() {
          _requesting = false;
        });
        AppSnackbar.show(context, message: 'OTP sent! Check your email.', type: AppSnackbarType.success);
        context.go(
          '/verify-reset-otp?identifier=${Uri.encodeComponent(identifier)}',
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AuthLayout(
      title: l10n.forgot_pwd_title,
      subtitle: l10n.forgot_pwd_subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.forgot_pwd_header,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.forgot_pwd_desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: _whatsappEnabled
                ? l10n.forgot_pwd_label_input
                : l10n.register_email,
            hint: _whatsappEnabled
                ? l10n.forgot_pwd_hint_input
                : 'student@gmail.com',
            controller: _identifier,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.email_outlined,
            errorText: _fieldErrors['identifier'] is List
                ? _fieldErrors['identifier'][0]
                : (_fieldErrors['identifier'] ?? _fieldErrors['email'])
                      ?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requesting ? null : _request,
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
                : Text(
                    l10n.forgot_pwd_btn_send,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              final state = GoRouterState.of(context);
              final redirectTo = state.uri.queryParameters['redirect_to'];
              if (redirectTo != null) {
                context.go(
                  '/login?redirect_to=${Uri.encodeComponent(redirectTo)}',
                );
              } else {
                context.go('/login');
              }
            },
            child: Text(
              l10n.forgot_pwd_back_to_signin,
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
