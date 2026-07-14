import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/profile/profile_screen.dart';
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

  bool _saveBusy = false;
  bool _photoBusy = false;
  Map<String, dynamic> _fieldErrors = {};

  /// Local file picked by the user – shown immediately before upload.
  File? _localPhoto;

  /// Cache-busted photo URL after a successful upload.
  String? _updatedPhotoUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _firstName = TextEditingController(text: p.firstName);
    _lastName = TextEditingController(text: p.lastName);
    _email = TextEditingController(text: p.email);
    _goal = TextEditingController(text: p.goal);
    _dob = TextEditingController(text: p.dob ?? '');
    _caste = TextEditingController(text: p.caste ?? '');
    _address = TextEditingController(text: p.address ?? '');
    _parentMobile = TextEditingController(text: p.parentMobile ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      final p = widget.profile;
      if (_firstName.text != p.firstName) _firstName.text = p.firstName;
      if (_lastName.text != p.lastName) _lastName.text = p.lastName;
      if (_email.text != p.email) _email.text = p.email;
      if (_goal.text != p.goal) _goal.text = p.goal;
      if (_dob.text != (p.dob ?? '')) _dob.text = p.dob ?? '';
      if (_caste.text != (p.caste ?? '')) _caste.text = p.caste ?? '';
      if (_address.text != (p.address ?? '')) _address.text = p.address ?? '';
      if (_parentMobile.text != (p.parentMobile ?? '')) {
        _parentMobile.text = p.parentMobile ?? '';
      }
      // Clear local photo preview so the server-fresh URL is used.
      _localPhoto = null;
      _updatedPhotoUrl = null;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _goal,
      _dob,
      _caste,
      _address,
      _parentMobile,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ──────────────────────────────── Actions ────────────────────────────────

  Future<void> _save() async {
    setState(() {
      _saveBusy = true;
      _fieldErrors = {};
    });
    try {
      final updated = await ref.read(studentApiProvider).updateProfile(
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
          profilePhoto: _updatedPhotoUrl ?? widget.profile.profilePhoto,
          parentMobile: _parentMobile.text.trim(),
        ),
      );
      // Update displayed photo URL from the server response if available.
      if (updated.profilePhoto != null && updated.profilePhoto!.isNotEmpty) {
        _updatedPhotoUrl = _cacheBust(updated.profilePhoto!);
      }
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
      if (mounted) setState(() => _saveBusy = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return;

    // Show local preview immediately.
    setState(() {
      _localPhoto = File(image.path);
      _photoBusy = true;
    });

    try {
      final photoUrl = await ref
          .read(studentApiProvider)
          .uploadProfilePhoto(image.path);

      if (mounted) {
        setState(() {
          // Cache-bust the new URL so CachedNetworkImage re-downloads it.
          _updatedPhotoUrl = photoUrl != null ? _cacheBust(photoUrl) : null;
          _localPhoto = null; // clear local preview; use the network URL now
        });
        ref.invalidate(profileProvider);
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.profile_photo_updated);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _localPhoto = null); // rollback local preview on error
        showSnack(context, failure.message);
      }
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  void _pickDob() async {
    // Parse existing value
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 18));
    if (_dob.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dob.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _dob.text = formatted);
    }
  }

  // ──────────────────────────────── Helpers ────────────────────────────────

  /// Appends a timestamp query param to force cache invalidation.
  String _cacheBust(String url) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}t=$ts';
  }

  String? _fieldError(String key) {
    final val = _fieldErrors[key];
    if (val is List && val.isNotEmpty) return val[0].toString();
    return val?.toString();
  }

  InputDecoration _dec(BuildContext context, String label, String key) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      errorText: _fieldError(key),
      filled: true,
      fillColor: theme.colorScheme.primaryContainer,
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

  // ──────────────────────────────── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    // Priority: local file picked → updated URL from server → original URL
    final currentPhotoUrl =
        _updatedPhotoUrl ?? widget.profile.profilePhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Avatar ──────────────────────────────────────────────────────
        Center(
          child: Stack(
            children: [
              _buildAvatar(currentPhotoUrl, theme),
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildCameraButton(theme),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 32),

        // ── Form ─────────────────────────────────────────────────────────
        Text(
          l10n.profile_personal_info,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),

        // First + Last Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _firstName,
                style: TextStyle(color: textColor),
                decoration: _dec(context, l10n.profile_first_name, 'first_name'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _lastName,
                style: TextStyle(color: textColor),
                decoration: _dec(context, l10n.profile_last_name, 'last_name'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor),
          decoration: _dec(context, l10n.profile_email, 'email'),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _goal,
          style: TextStyle(color: textColor),
          decoration: _dec(context, l10n.profile_goal, 'goal'),
        ),
        const SizedBox(height: 16),

        // DOB with date-picker
        GestureDetector(
          onTap: _pickDob,
          child: AbsorbPointer(
            child: TextField(
              controller: _dob,
              style: TextStyle(color: textColor),
              decoration: _dec(context, l10n.profile_dob, 'dob').copyWith(
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
            ),
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
          decoration: _dec(
            context,
            l10n.profile_parent_mobile,
            'parent_mobile',
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _caste,
          style: TextStyle(color: textColor),
          decoration: _dec(context, l10n.profile_caste, 'caste'),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _address,
          maxLines: 3,
          style: TextStyle(color: textColor),
          decoration: _dec(context, l10n.profile_address, 'address'),
        ),
        const SizedBox(height: 32),

        // ── Save button ───────────────────────────────────────────────────
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: (_saveBusy || _photoBusy) ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _saveBusy
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.profile_save_changes,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? photoUrl, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    const size = 120.0;

    Widget avatar;
    if (_localPhoto != null) {
      // Immediately show the locally-picked file before upload finishes.
      avatar = ClipOval(
        child: Image.file(
          _localPhoto!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: photoUrl,
        imageBuilder: (ctx, imageProvider) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (ctx, url) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (ctx, url, err) => _defaultAvatarContainer(isDark, size),
        // Force re-download by using the cache-busted URL as key.
        cacheKey: photoUrl,
      );
    } else {
      avatar = _defaultAvatarContainer(isDark, size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          width: 4,
        ),
      ),
      child: ClipOval(child: SizedBox(width: size, height: size, child: avatar)),
    );
  }

  Widget _defaultAvatarContainer(bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }

  Widget _buildCameraButton(ThemeData theme) {
    return GestureDetector(
      onTap: (_photoBusy || _saveBusy) ? null : _uploadPhoto,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _photoBusy ? Colors.grey : theme.colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _photoBusy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.camera_alt, size: 20, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
