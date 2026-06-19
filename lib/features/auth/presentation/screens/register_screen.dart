import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // keep old showSnack import
import '../auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _step = 1;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _dob = TextEditingController();
  final _caste = TextEditingController();
  final _address = TextEditingController();
  final _parentMobile = TextEditingController();
  final _password = TextEditingController();
  String _goal = 'Other';
  bool _busy = false;
  bool _obscurePassword = true;

  static const goals = [
    'UPSC', 'GPSC', 'CONSTABLE', 'Banking', 'Army',
    'Teacher', 'Railway', 'SSC', 'CA', 'Other',
  ];

  @override
  void dispose() {
    for (final controller in [
      _firstName, _lastName, _email, _mobile, _dob, _caste, _address, _parentMobile, _password,
    ]) {
      controller.dispose();
    }
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

  Future<void> _register() async {
    setState(() => _busy = true);
    final ok = await ref.read(authControllerProvider.notifier).register({
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'email': _email.text.trim(),
      'mobile': _mobile.text.trim(),
      'password': _password.text,
      'confirm_password': _password.text,
      'goal': _goal,
      'dob': _dob.text.trim(),
      'caste': _caste.text.trim(),
      'address': _address.text.trim(),
      'parent_mobile': _parentMobile.text.trim(),
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      context.go('/home');
    } else {
      _handleError(ref.read(authControllerProvider), 'Registration failed.');
    }
  }

  Future<void> _pickDob() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dob.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final fieldErrors = auth.fieldErrors ?? const {};
    final theme = Theme.of(context);

    String? errorFor(String field) {
      final fieldError = fieldErrors[field];
      if (fieldError is List && fieldError.isNotEmpty) return fieldError.first.toString();
      return fieldError?.toString();
    }

    if (_step == 1) {
      return AuthLayout(
        title: 'Create Account',
        subtitle: 'Join us to access exclusive features',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 1 of 2: Personal Info',
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    label: 'First Name',
                    hint: 'John',
                    controller: _firstName,
                    errorText: errorFor('first_name'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    label: 'Last Name',
                    hint: 'Doe',
                    controller: _lastName,
                    errorText: errorFor('last_name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Email Address',
              hint: 'john.doe@example.com',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              suffixIcon: Icons.email_outlined,
              errorText: errorFor('email'),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Mobile Number',
              hint: 'Your mobile number',
              controller: _mobile,
              keyboardType: TextInputType.phone,
              suffixIcon: Icons.phone_android,
              errorText: errorFor('mobile'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() => _step = 2);
              },
              child: const Text('Continue'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?', style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Sign In', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return AuthLayout(
      title: 'Almost There',
      subtitle: 'We need a little more info to get you started',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 2 of 2: Profile Details',
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Birthday',
            hint: 'YYYY-MM-DD',
            controller: _dob,
            readOnly: true,
            onTap: _pickDob,
            suffixIcon: Icons.calendar_today_outlined,
            errorText: errorFor('dob'),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Goal',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _goal,
                items: goals.map((goal) => DropdownMenuItem(value: goal, child: Text(goal))).toList(),
                onChanged: (value) => setState(() => _goal = value ?? 'Other'),
                decoration: const InputDecoration(), // Inherits from theme
              ),
            ],
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Caste (Optional)',
            hint: 'E.g. General, OBC, SC, ST',
            controller: _caste,
            errorText: errorFor('caste'),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Parent Mobile (Optional)',
            hint: 'Emergency Contact',
            controller: _parentMobile,
            keyboardType: TextInputType.phone,
            errorText: errorFor('parent_mobile'),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Full Address',
            hint: 'Your Home Address',
            controller: _address,
            maxLines: 2,
            errorText: errorFor('address'),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Password',
            hint: '********',
            controller: _password,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            errorText: errorFor('password'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _busy ? null : _register,
            child: _busy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Create Account'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() => _step = 1);
            },
            child: Text('Back to Step 1', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}
