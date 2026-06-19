import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // Keep old path for showSnack for now
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';

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
      showSnack(context, 'Please correct the errors in the form.');
    }
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    final controller = ref.read(authControllerProvider.notifier);
    
    final input = _email.text.trim();
    final isMobile = RegExp(r'^[0-9]+$').hasMatch(input);
    final ok = isMobile
        ? await controller.loginMobile(input, _password.text)
        : await controller.loginEmail(input, _password.text);
        
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      context.go('/home');
    } else {
      _handleError(ref.read(authControllerProvider), 'Login failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final disabled = _busy || auth.isLoading;
    final fieldErrors = auth.fieldErrors ?? const {};
    final theme = Theme.of(context);

    String? errorFor(String field) {
      final fieldError = fieldErrors[field];
      if (fieldError is List && fieldError.isNotEmpty) return fieldError.first.toString();
      return fieldError?.toString();
    }

    return AuthLayout(
      title: 'Welcome Back',
      subtitle: 'Sign in to continue your learning journey',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In',
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Email / Mobile',
            hint: 'Enter your email or mobile',
            controller: _email,
            suffixIcon: Icons.person_outline,
            errorText: errorFor('email') ?? errorFor('mobile') ?? errorFor('username'),
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _password,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            errorText: errorFor('password'),
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
                    ),
                    Flexible(
                      child: Text(
                        'Remember me', 
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: Text('Forgot Password?', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: disabled ? null : _login,
            child: disabled
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Text('Sign Up', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
