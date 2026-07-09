import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // Keep old path for showSnack for now
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  final Map<String, String> _clientErrors = {};

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _handleError(AuthState auth, String defaultMsg) {
    final errors = auth.fieldErrors ?? {};
    final nonField = errors['non_field_errors'] ?? errors['detail'];
    if (nonField != null) {
      final msg = nonField is List ? nonField.first.toString() : nonField.toString();
      showSnack(context, msg);
    } else if (errors.isEmpty) {
      showSnack(context, auth.error ?? defaultMsg);
    } else {
      // Don't show snack for field errors, as they are shown below the text fields
    }
  }

  Future<void> _login() async {
    if (_busy) return;

    final l10n = AppLocalizations.of(context)!;
    final input = _email.text.trim();
    final password = _password.text;

    setState(() {
      _clientErrors.clear();
    });

    bool hasError = false;

    if (input.isEmpty) {
      _clientErrors['email'] = l10n.err_required;
      hasError = true;
    } else {
      final isMobile = RegExp(r'^[0-9]+$').hasMatch(input);
      if (isMobile && !RegExp(r'^[0-9]{10}$').hasMatch(input)) {
        _clientErrors['email'] = l10n.err_invalid_mobile;
        hasError = true;
      } else if (!isMobile && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input)) {
        _clientErrors['email'] = l10n.err_invalid_email;
        hasError = true;
      }
    }

    if (password.isEmpty) {
      _clientErrors['password'] = l10n.err_required;
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _busy = true);
    final controller = ref.read(authControllerProvider.notifier);
    
    final isMobile = RegExp(r'^[0-9]+$').hasMatch(input);
    final ok = isMobile
        ? await controller.loginMobile(input, password)
        : await controller.loginEmail(input, password);
        
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showSnack(context, l10n.login_success);
      final state = GoRouterState.of(context);
      final redirectTo = state.uri.queryParameters['redirect_to'];
      if (redirectTo != null && redirectTo.isNotEmpty) {
        context.go(Uri.decodeComponent(redirectTo));
      } else {
        context.go('/home');
      }
    } else {
      _handleError(ref.read(authControllerProvider), l10n.login_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final disabled = _busy || auth.isLoading;
    final fieldErrors = auth.fieldErrors ?? const {};

    String? errorFor(String field) {
      if (_clientErrors.containsKey(field)) return _clientErrors[field];
      final fieldError = fieldErrors[field];
      if (fieldError is List && fieldError.isNotEmpty) return fieldError.first.toString();
      return fieldError?.toString();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AuthLayout(
      title: l10n.login_title,
      subtitle: l10n.login_subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.login_btn,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: l10n.login_email_mobile_label,
            hint: l10n.login_email_mobile_hint,
            controller: _email,
            suffixIcon: Icons.person_outline,
            errorText: errorFor('email') ?? errorFor('mobile') ?? errorFor('username'),
            onChanged: (val) {
              if (_clientErrors.isNotEmpty) {
                setState(() => _clientErrors.clear());
              }
            },
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: l10n.login_password_label,
            hint: l10n.login_password_hint,
            controller: _password,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            errorText: errorFor('password'),
            onChanged: (val) {
              if (_clientErrors.containsKey('password')) {
                setState(() => _clientErrors.remove('password'));
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      activeColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Flexible(
                      child: Text(
                        l10n.login_remember_me, 
                        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  final state = GoRouterState.of(context);
                  final redirectTo = state.uri.queryParameters['redirect_to'];
                  if (redirectTo != null) {
                    context.go('/forgot-password?redirect_to=${Uri.encodeComponent(redirectTo)}');
                  } else {
                    context.go('/forgot-password');
                  }
                },
                child: Text(l10n.login_forgot_pwd, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: disabled ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: disabled
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2),
                  )
                : Text(l10n.login_btn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.login_no_acc, style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
              TextButton(
                onPressed: () {
                  final state = GoRouterState.of(context);
                  final redirectTo = state.uri.queryParameters['redirect_to'];
                  if (redirectTo != null) {
                    context.go('/register?redirect_to=${Uri.encodeComponent(redirectTo)}');
                  } else {
                    context.go('/register');
                  }
                },
                child: Text(l10n.login_sign_up, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
