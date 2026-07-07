import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart'; // keep old showSnack import
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
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
  final _otp = TextEditingController();
  final _dob = TextEditingController();
  final _address = TextEditingController();
  final _parentMobile = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String _goal = 'Other';
  String _gender = 'Male';
  bool _busy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpSent = false;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  bool _otpVerified = false;
  Timer? _resendTimer;
  Timer? _configPollingTimer;
  int _resendSeconds = 0;
  bool _requireOtp = false;
  final Map<String, String> _clientErrors = {};

  static const goals = [
    'UPSC', 'GPSC', 'CONSTABLE', 'Banking', 'Army',
    'Teacher', 'Railway', 'SSC', 'CA', 'Other',
  ];

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _otpFocus = FocusNode();
  final _dobFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailFocusChange);
    _mobileFocus.addListener(_onMobileFocusChange);
    _fetchConfig();
    _configPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchConfig());
  }

  Future<void> _fetchConfig() async {
    try {
      final info = await ref.read(studentApiProvider).libraryInfo();
      if (mounted && _requireOtp != info.enableWhatsappService) {
        setState(() {
          _requireOtp = info.enableWhatsappService;
          if (!_requireOtp) {
            _otpSent = false;
            _verifyingOtp = false;
            _sendingOtp = false;
            _otp.clear();
            _resendTimer?.cancel();
            _resendSeconds = 0;
            _clientErrors.remove('otp');
          }
        });
      }
    } catch (_) {}
  }

  void _onEmailFocusChange() {
    if (!_emailFocus.hasFocus && _email.text.trim().isNotEmpty) {
      _checkAvailability(email: _email.text.trim());
    }
  }

  void _onMobileFocusChange() {
    if (!_mobileFocus.hasFocus && _mobile.text.trim().isNotEmpty) {
      _checkAvailability(mobile: _mobile.text.trim());
    }
  }

  Future<void> _checkAvailability({String? email, String? mobile}) async {
    if (email != null && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) email = null;
    if (mobile != null && !RegExp(r'^[0-9]{10}$').hasMatch(mobile)) mobile = null;

    if (email == null && mobile == null) return;

    try {
      final reqOtp = await ref.read(authControllerProvider.notifier).checkAvailability(email: email, mobile: mobile);
      if (mounted && mobile != null) {
        setState(() => _requireOtp = reqOtp);
      }
    } catch (e) {
      if (e is ApiFailure && e.errors != null && e.errors is Map<String, dynamic>) {
        final errorsMap = e.errors as Map<String, dynamic>;
        setState(() {
          if (email != null && errorsMap['email'] != null) {
            final msg = errorsMap['email'] is List ? errorsMap['email'][0] : errorsMap['email'];
            _clientErrors['email'] = msg.toString();
          }
          if (mobile != null && errorsMap['mobile'] != null) {
            final msg = errorsMap['mobile'] is List ? errorsMap['mobile'][0] : errorsMap['mobile'];
            _clientErrors['mobile'] = msg.toString();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _configPollingTimer?.cancel();
    for (final controller in [
      _firstName, _lastName, _email, _mobile, _otp, _dob, _address, _parentMobile, _password, _confirmPassword,
    ]) {
      controller.dispose();
    }
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _otpFocus.dispose();
    _dobFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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

  Future<void> _sendOtp() async {
    if (_sendingOtp) return;
    final mobile = _mobile.text.trim();
    if (mobile.length != 10) {
      setState(() => _clientErrors['mobile'] = 'Enter a valid 10-digit mobile number.');
      return;
    }
    setState(() {
      _sendingOtp = true;
      _clientErrors.remove('mobile');
      _clientErrors.remove('otp');
    });
    try {
      await ref.read(authControllerProvider.notifier).sendRegisterOtp(mobile);
      if (mounted) {
        setState(() {
          _otpSent = true;
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
        showSnack(context, 'OTP sent to your WhatsApp successfully!');
      }
    } on ApiFailure catch (e) {
      if (mounted) {
        if (e.errors is Map<String, dynamic> && (e.errors as Map<String, dynamic>).containsKey('mobile')) {
           final msg = (e.errors as Map<String, dynamic>)['mobile'];
           setState(() => _clientErrors['mobile'] = msg is List ? msg[0] : msg.toString());
        } else {
           showSnack(context, e.message);
        }
      }
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_verifyingOtp) return;
    final mobile = _mobile.text.trim();
    final otp = _otp.text.trim();
    
    if (otp.isEmpty) {
      setState(() => _clientErrors['otp'] = 'OTP is required.');
      return;
    }
    if (otp.length != 6) {
      setState(() => _clientErrors['otp'] = 'Enter a valid 6-digit OTP.');
      return;
    }

    setState(() {
      _verifyingOtp = true;
      _clientErrors.remove('otp');
    });

    try {
      await ref.read(authControllerProvider.notifier).verifyRegisterOtp(mobile, otp);
      if (mounted) {
        setState(() {
          _otpVerified = true;
          _resendTimer?.cancel();
        });
        showSnack(context, 'Mobile number verified successfully!');
      }
    } on ApiFailure catch (e) {
      if (mounted) {
        if (e.errors is Map<String, dynamic> && (e.errors as Map<String, dynamic>).containsKey('otp')) {
           final msg = (e.errors as Map<String, dynamic>)['otp'];
           setState(() => _clientErrors['otp'] = msg is List ? msg[0] : msg.toString());
        } else {
           setState(() => _clientErrors['otp'] = e.message);
        }
      }
    } finally {
      if (mounted) setState(() => _verifyingOtp = false);
    }
  }

  Future<void> _register() async {
    if (_busy) return;

    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final email = _email.text.trim();
    final mobile = _mobile.text.trim();
    final otp = _otp.text.trim();
    final dob = _dob.text.trim();
    final password = _password.text;
    final confirmPassword = _confirmPassword.text;

    final duplicateMobile = _clientErrors['mobile'] == 'Mobile number already exists.';
    final duplicateEmail = _clientErrors['email'] == 'Email already exists.';

    setState(() {
      _clientErrors.clear();
      if (duplicateMobile) _clientErrors['mobile'] = 'Mobile number already exists.';
      if (duplicateEmail) _clientErrors['email'] = 'Email already exists.';
    });

    bool hasError = false;
    FocusNode? firstErrorFocus;

    void addError(String field, String message, FocusNode focusNode) {
      if (!_clientErrors.containsKey(field)) {
        _clientErrors[field] = message;
      }
      hasError = true;
      firstErrorFocus ??= focusNode;
    }

    if (firstName.isEmpty) { addError('first_name', 'First name is required', _firstNameFocus); }
    if (lastName.isEmpty) { addError('last_name', 'Last name is required', _lastNameFocus); }
    
    if (email.isEmpty) {
      addError('email', 'Email is required', _emailFocus);
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      addError('email', 'Please enter a valid email address.', _emailFocus);
    } else if (duplicateEmail) {
      hasError = true;
      firstErrorFocus ??= _emailFocus;
    }

    if (mobile.isEmpty) {
      addError('mobile', 'Mobile number is required', _mobileFocus);
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      addError('mobile', 'Mobile number must be exactly 10 digits.', _mobileFocus);
    } else if (duplicateMobile) {
      hasError = true;
      firstErrorFocus ??= _mobileFocus;
    }
    
    if (_requireOtp && otp.isEmpty) {
      addError('otp', 'OTP is required.', _otpFocus);
    }

    if (dob.isEmpty) { addError('dob', 'Birthday is required', _dobFocus); }
    
    if (password.isEmpty) {
      addError('password', 'Password is required', _passwordFocus);
    } else if (password.length < 6) {
      addError('password', 'Password must be at least 6 characters long', _passwordFocus);
    }

    if (confirmPassword.isEmpty) {
      addError('confirm_password', 'Confirm password is required', _confirmPasswordFocus);
    } else if (password != confirmPassword) {
      addError('confirm_password', 'Passwords do not match', _confirmPasswordFocus);
    }

    if (hasError) {
      setState(() {});
      if (_step == 2 && (_clientErrors.containsKey('first_name') || _clientErrors.containsKey('last_name') || _clientErrors.containsKey('email') || _clientErrors.containsKey('mobile') || _clientErrors.containsKey('otp'))) {
        setState(() => _step = 1);
        showSnack(context, 'Please fix errors in Step 1');
      }
      firstErrorFocus?.requestFocus();
      return;
    }

    setState(() => _busy = true);
    final ok = await ref.read(authControllerProvider.notifier).register({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'otp': otp,
      'password': password,
      'confirm_password': confirmPassword,
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
      final state = GoRouterState.of(context);
      final redirectTo = state.uri.queryParameters['redirect_to'];
      if (redirectTo != null && redirectTo.isNotEmpty) {
        context.go(Uri.decodeComponent(redirectTo));
      } else {
        context.go('/home');
      }
    } else {
      final auth = ref.read(authControllerProvider);
      final fieldErrors = auth.fieldErrors ?? {};
      if (_step == 2 && (fieldErrors.containsKey('first_name') || fieldErrors.containsKey('last_name') || fieldErrors.containsKey('email') || fieldErrors.containsKey('mobile') || fieldErrors.containsKey('otp'))) {
        setState(() {
          _step = 1;
          if (fieldErrors.containsKey('mobile') || fieldErrors.containsKey('otp')) {
            _otpVerified = false;
            _otpSent = false;
          }
        });
        showSnack(context, 'Please fix errors in Step 1');
      } else {
        _handleError(auth, 'Registration failed.');
      }
    }
  }

  Future<void> _pickDob() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme: isDark 
                ? const ColorScheme.dark(
                    primary: Color(0xFF917CFF),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E2C),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF917CFF),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF140C2C),
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              headerBackgroundColor: const Color(0xFF917CFF),
              headerForegroundColor: Colors.white,
              backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
              dayStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Outfit'),
              yearStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
              weekdayStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF917CFF),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          child: child!,
        );
      },
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    label: 'First Name',
                    hint: 'John',
                    controller: _firstName,
                    focusNode: _firstNameFocus,
                    errorText: errorFor('first_name'),
                    onChanged: (val) {
                      if (_clientErrors.containsKey('first_name')) {
                        setState(() => _clientErrors.remove('first_name'));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    label: 'Last Name',
                    hint: 'Doe',
                    controller: _lastName,
                    focusNode: _lastNameFocus,
                    errorText: errorFor('last_name'),
                    onChanged: (val) {
                      if (_clientErrors.containsKey('last_name')) {
                        setState(() => _clientErrors.remove('last_name'));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AuthTextField(
              label: 'Email Address',
              hint: 'john.doe@example.com',
              controller: _email,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              suffixIcon: Icons.email_outlined,
              errorText: errorFor('email'),
              onChanged: (val) {
                if (_clientErrors.containsKey('email')) {
                  setState(() => _clientErrors.remove('email'));
                }
              },
            ),
            const SizedBox(height: 12),
            AuthTextField(
              label: 'Mobile Number',
              hint: 'Your mobile number',
              controller: _mobile,
              focusNode: _mobileFocus,
              keyboardType: TextInputType.phone,
              suffixIcon: (_requireOtp && _otpVerified) ? Icons.check_circle : Icons.phone_android,
              iconColor: (_requireOtp && _otpVerified) ? Colors.green : null,
              borderColor: (_requireOtp && _otpVerified) ? Colors.green : null,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              errorText: errorFor('mobile'),
              onChanged: (val) {
                if (_requireOtp && (_otpVerified || _otpSent)) {
                  setState(() {
                    _otpVerified = false;
                    _otpSent = false;
                    _otp.clear();
                  });
                }
                if (_clientErrors.containsKey('mobile')) {
                  setState(() => _clientErrors.remove('mobile'));
                }
                if (val.length == 10) {
                  _checkAvailability(mobile: val);
                }
              },
            ),
            if (_requireOtp && _otpVerified)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            if (_requireOtp && _otpSent && !_otpVerified) ...[
              const SizedBox(height: 12),
              AuthTextField(
                label: 'OTP (Sent to WhatsApp)',
                hint: 'Enter 6-digit OTP',
                controller: _otp,
                focusNode: _otpFocus,
                keyboardType: TextInputType.number,
                suffixIcon: Icons.message_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                errorText: errorFor('otp'),
                onChanged: (val) {
                  if (_clientErrors.containsKey('otp')) {
                    setState(() => _clientErrors.remove('otp'));
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _resendSeconds > 0 || _sendingOtp || _verifyingOtp ? null : _sendOtp,
                    child: _sendingOtp 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            _resendSeconds > 0 ? 'Resend OTP in ${_resendSeconds}s' : 'Resend OTP', 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _resendSeconds > 0 ? Colors.grey : Theme.of(context).colorScheme.primary,
                            )
                          ),
                  ),
                  ElevatedButton(
                    onPressed: _verifyingOtp ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _verifyingOtp
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Verify OTP'),
                  ),
                ],
              ),
            ] else if (_requireOtp && !_otpVerified) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _sendOtp,
                  child: _sendingOtp 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send Verification OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                bool hasError = false;
                FocusNode? firstErrorFocus;

                void addError(String key, String msg, FocusNode fn) {
                  _clientErrors[key] = msg;
                  hasError = true;
                  firstErrorFocus ??= fn;
                }

                if (_firstName.text.trim().isEmpty) addError('first_name', 'First name is required', _firstNameFocus);
                if (_lastName.text.trim().isEmpty) addError('last_name', 'Last name is required', _lastNameFocus);
                if (_email.text.trim().isEmpty) addError('email', 'Email is required', _emailFocus);
                if (_mobile.text.trim().isEmpty) addError('mobile', 'Mobile number is required', _mobileFocus);

                if (hasError) {
                  setState(() {});
                  showSnack(context, 'Please fill all required fields in Step 1');
                  firstErrorFocus?.requestFocus();
                  return;
                }

                if (_requireOtp && !_otpVerified) {
                  showSnack(context, 'Please verify your mobile number first.');
                  return;
                }
                setState(() => _step = 2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF917CFF),
                foregroundColor: const Color(0xFF140C2C),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?', style: TextStyle(color: Colors.black54)),
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
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'Birthday',
                  hint: 'YYYY-MM-DD',
                  controller: _dob,
                  focusNode: _dobFocus,
                  readOnly: true,
                  onTap: _pickDob,
                  suffixIcon: Icons.calendar_today_outlined,
                  errorText: errorFor('dob'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF140C2C)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _gender = 'Male'),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: 'Male',
                                    groupValue: _gender,
                                    onChanged: (val) => setState(() => _gender = val!),
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    fillColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) return Theme.of(context).colorScheme.primary;
                                      return Colors.grey.shade400;
                                    }),
                                  ),
                                  const SizedBox(width: 4),
                                  const Flexible(
                                    child: Text('Male', style: TextStyle(fontSize: 13, color: Colors.black), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _gender = 'Female'),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: 'Female',
                                    groupValue: _gender,
                                    onChanged: (val) => setState(() => _gender = val!),
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    fillColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) return Theme.of(context).colorScheme.primary;
                                      return Colors.grey.shade400;
                                    }),
                                  ),
                                  const SizedBox(width: 4),
                                  const Flexible(
                                    child: Text('Female', style: TextStyle(fontSize: 13, color: Colors.black), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Study Goal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF140C2C)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _goal,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF140C2C)),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      items: goals.map((goal) => DropdownMenuItem(value: goal, child: Text(goal, style: const TextStyle(color: Colors.black)))).toList(),
                      onChanged: (value) => setState(() => _goal = value ?? 'Other'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF1EFFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFCBB9FF), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFCBB9FF), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF917CFF), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  label: 'Parent Mobile',
                  hint: 'Optional',
                  controller: _parentMobile,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  errorText: errorFor('parent_mobile'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AuthTextField(
            label: 'Full Address',
            hint: 'Your Home Address',
            controller: _address,
            maxLines: 2,
            errorText: errorFor('address'),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'Password',
                  hint: '********',
                  controller: _password,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  errorText: errorFor('password'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  label: 'Confirm Pass',
                  hint: '********',
                  controller: _confirmPassword,
                  focusNode: _confirmPasswordFocus,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  errorText: errorFor('confirm_password'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF917CFF),
              foregroundColor: const Color(0xFF140C2C),
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
                    child: CircularProgressIndicator(color: Color(0xFF140C2C), strokeWidth: 2),
                  )
                : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 12),
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
