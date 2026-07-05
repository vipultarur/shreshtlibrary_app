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

    final input = _email.text.trim();
    final password = _password.text;

    setState(() {
      _clientErrors.clear();
    });

    bool hasError = false;

    if (input.isEmpty) {
      _clientErrors['email'] = 'Email or mobile number is required';
      hasError = true;
    } else {
      final isMobile = RegExp(r'^[0-9]+$').hasMatch(input);
      if (isMobile && !RegExp(r'^[0-9]{10}$').hasMatch(input)) {
        _clientErrors['email'] = 'Mobile number must contain exactly 10 digits.';
        hasError = true;
      } else if (!isMobile && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input)) {
        _clientErrors['email'] = 'Please enter a valid email address.';
        hasError = true;
      }
    }

    if (password.isEmpty) {
      _clientErrors['password'] = 'Password is required';
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
      showSnack(context, 'Login successful!');
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

    String? errorFor(String field) {
      if (_clientErrors.containsKey(field)) return _clientErrors[field];
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
          const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF140C2C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Email / Mobile',
            hint: 'Enter your email or mobile',
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
            label: 'Password',
            hint: 'Enter your password',
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
                      activeColor: const Color(0xFF140C2C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    const Flexible(
                      child: Text(
                        'Remember me', 
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: disabled ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF917CFF),
              foregroundColor: const Color(0xFF140C2C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: disabled
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Color(0xFF140C2C), strokeWidth: 2),
                  )
                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?", style: TextStyle(color: Colors.black54)),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Sign Up', style: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
