import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/profile/profile_screen.dart'; // To access profileProvider
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

class ProfileEditor extends ConsumerStatefulWidget {
  const ProfileEditor({super.key, required this.profile});

  final StudentProfile profile;

  @override
  ConsumerState<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<ProfileEditor> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _goal;
  late final TextEditingController _dob;
  late final TextEditingController _caste;
  late final TextEditingController _address;
  late final TextEditingController _parentMobile;
  bool _busy = false;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _firstName = TextEditingController(text: profile.firstName);
    _lastName = TextEditingController(text: profile.lastName);
    _email = TextEditingController(text: profile.email);
    _goal = TextEditingController(text: profile.goal);
    _dob = TextEditingController(text: profile.dob);
    _caste = TextEditingController(text: profile.caste);
    _address = TextEditingController(text: profile.address);
    _parentMobile = TextEditingController(text: profile.parentMobile);
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _goal,
      _dob,
      _caste,
      _address,
      _parentMobile,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _fieldErrors = {};
    });
    try {
      await ref
          .read(studentApiProvider)
          .updateProfile(
            StudentProfile(
              username: widget.profile.username,
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              email: _email.text.trim(),
              mobile: widget.profile.mobile,
              goal: _goal.text.trim(),
              dob: _dob.text.trim(),
              caste: _caste.text.trim(),
              address: _address.text.trim(),
              profilePhoto: widget.profile.profilePhoto,
              parentMobile: _parentMobile.text.trim(),
            ),
          );
      ref.invalidate(profileProvider);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.profile_updated);
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(studentApiProvider).uploadProfilePhoto(image.path);
      ref.invalidate(profileProvider);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.profile_photo_updated);
      }
    } on ApiFailure catch (failure) {
      if (mounted) showSnack(context, failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context, String label, String? errorText) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.profile.profilePhoto;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100, width: 4),
                  image: photo != null && photo.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(photo),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photo == null || photo.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _busy ? null : _uploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${widget.profile.firstName} ${widget.profile.lastName}'.trim(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Center(
          child: Text(
            widget.profile.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.profile_personal_info,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _firstName,
                style: TextStyle(color: textColor),
                decoration: _buildInputDecoration(
                  context,
                  l10n.profile_first_name,
                  _fieldErrors['first_name'] is List ? _fieldErrors['first_name'][0] : _fieldErrors['first_name']?.toString(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _lastName,
                style: TextStyle(color: textColor),
                decoration: _buildInputDecoration(
                  context,
                  l10n.profile_last_name,
                  _fieldErrors['last_name'] is List ? _fieldErrors['last_name'][0] : _fieldErrors['last_name']?.toString(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            context,
            l10n.profile_email,
            _fieldErrors['email'] is List ? _fieldErrors['email'][0] : _fieldErrors['email']?.toString(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _goal,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            context,
            l10n.profile_goal,
            _fieldErrors['goal'] is List ? _fieldErrors['goal'][0] : _fieldErrors['goal']?.toString(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dob,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            context,
            l10n.profile_dob,
            _fieldErrors['dob'] is List ? _fieldErrors['dob'][0] : _fieldErrors['dob']?.toString(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _parentMobile,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: textColor),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: _buildInputDecoration(
            context,
            l10n.profile_parent_mobile,
            _fieldErrors['parent_mobile'] is List ? _fieldErrors['parent_mobile'][0] : _fieldErrors['parent_mobile']?.toString(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _caste,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            context,
            l10n.profile_caste,
            _fieldErrors['caste'] is List ? _fieldErrors['caste'][0] : _fieldErrors['caste']?.toString(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _address,
          maxLines: 3,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            context,
            l10n.profile_address,
            _fieldErrors['address'] is List ? _fieldErrors['address'][0] : _fieldErrors['address']?.toString(),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _busy
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    l10n.profile_save_changes,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
