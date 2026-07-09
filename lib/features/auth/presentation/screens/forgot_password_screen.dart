import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // keep old showSnack import
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, isEmail ? l10n.forgot_pwd_snack_email : l10n.forgot_pwd_snack_whatsapp);
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
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.forgot_pwd_snack_success);
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
            style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: l10n.forgot_pwd_label_input,
            hint: l10n.forgot_pwd_hint_input,
            controller: _identifier,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.account_circle_outlined,
            errorText: _fieldErrors['identifier'] is List ? _fieldErrors['identifier'][0] : (_fieldErrors['identifier'] ?? _fieldErrors['email'])?.toString(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requesting || _resendSeconds > 0 ? null : _request,
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
                : Text(
                    _resendSeconds > 0 ? l10n.forgot_pwd_btn_resend(_resendSeconds.toString()) : l10n.forgot_pwd_btn_send,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(l10n.forgot_pwd_or, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            l10n.forgot_pwd_token_desc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: l10n.forgot_pwd_label_token,
            hint: l10n.forgot_pwd_hint_token,
            controller: _token,
            suffixIcon: Icons.vpn_key_outlined,
            errorText: _fieldErrors['token'] is List ? _fieldErrors['token'][0] : _fieldErrors['token']?.toString(),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: l10n.forgot_pwd_label_new_pwd,
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
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(l10n.forgot_pwd_btn_reset, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
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
            child: Text(l10n.forgot_pwd_back_to_signin, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
