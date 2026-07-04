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
  final _address = TextEditingController();
  final _parentMobile = TextEditingController();
  final _password = TextEditingController();
  String _goal = 'Other';
  String _gender = 'Other';
  bool _busy = false;
  bool _obscurePassword = true;
  final Map<String, String> _clientErrors = {};

  static const goals = [
    'UPSC', 'GPSC', 'CONSTABLE', 'Banking', 'Army',
    'Teacher', 'Railway', 'SSC', 'CA', 'Other',
  ];

  @override
  void dispose() {
    for (final controller in [
      _firstName, _lastName, _email, _mobile, _dob, _address, _parentMobile, _password,
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
      // Don't show snack for field errors, as they are shown below the text fields
    }
  }

  Future<void> _register() async {
    if (_busy) return;

    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final email = _email.text.trim();
    final mobile = _mobile.text.trim();
    final dob = _dob.text.trim();
    final password = _password.text;

    setState(() {
      _clientErrors.clear();
    });

    bool hasError = false;

    if (firstName.isEmpty) { _clientErrors['first_name'] = 'First name is required'; hasError = true; }
    if (lastName.isEmpty) { _clientErrors['last_name'] = 'Last name is required'; hasError = true; }
    
    if (email.isEmpty) {
      _clientErrors['email'] = 'Email is required';
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _clientErrors['email'] = 'Enter a valid email address';
      hasError = true;
    }

    if (mobile.isEmpty) {
      _clientErrors['mobile'] = 'Mobile number is required';
      hasError = true;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      _clientErrors['mobile'] = 'Enter a valid 10-digit mobile number';
      hasError = true;
    }

    if (dob.isEmpty) { _clientErrors['dob'] = 'Birthday is required'; hasError = true; }
    
    if (password.isEmpty) {
      _clientErrors['password'] = 'Password is required';
      hasError = true;
    } else if (password.length < 6) {
      _clientErrors['password'] = 'Password must be at least 6 characters long';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      if (_step == 2 && (_clientErrors.containsKey('first_name') || _clientErrors.containsKey('last_name') || _clientErrors.containsKey('email') || _clientErrors.containsKey('mobile'))) {
        setState(() => _step = 1);
        showSnack(context, 'Please fix errors in Step 1');
      }
      return;
    }

    setState(() => _busy = true);
    final ok = await ref.read(authControllerProvider.notifier).register({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'confirm_password': password,
      'goal': _goal,
      'gender': _gender,
      'dob': dob,
      'address': _address.text.trim(),
      'parent_mobile': _parentMobile.text.trim(),
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showSnack(context, 'Registration successful!');
      context.go('/home');
    } else {
      final auth = ref.read(authControllerProvider);
      final fieldErrors = auth.fieldErrors ?? {};
      if (_step == 2 && (fieldErrors.containsKey('first_name') || fieldErrors.containsKey('last_name') || fieldErrors.containsKey('email') || fieldErrors.containsKey('mobile'))) {
        setState(() => _step = 1);
        showSnack(context, 'Please fix errors in Step 1');
      } else {
        _handleError(auth, 'Registration failed.');
      }
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

    String? errorFor(String field) {
      if (_clientErrors.containsKey(field)) return _clientErrors[field];
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
            const Text(
              'Step 1 of 2: Personal Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF140C2C)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF140C2C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?', style: TextStyle(color: Colors.black54)),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign In', style: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.bold)),
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
          const Text(
            'Step 2 of 2: Profile Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF140C2C)),
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
              const Text(
                'Study Goal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF140C2C)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _goal,
                items: goals.map((goal) => DropdownMenuItem(value: goal, child: Text(goal))).toList(),
                onChanged: (value) => setState(() => _goal = value ?? 'Other'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBB9FF), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gender',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF140C2C)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _gender = value ?? 'Other'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBB9FF), width: 2),
                  ),
                ),
              ),
            ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF140C2C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _busy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() => _step = 1);
            },
            child: const Text('Back to Step 1', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
