import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/profile/profile_screen.dart'; // To access profileProvider

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
      if (mounted) showSnack(context, 'Profile updated.');
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
      if (mounted) showSnack(context, 'Photo updated.');
    } on ApiFailure catch (failure) {
      if (mounted) showSnack(context, failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.profile.profilePhoto;
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundImage: photo == null
              ? null
              : CachedNetworkImageProvider(photo),
          child: photo == null ? const Icon(Icons.person, size: 44) : null,
        ),
        TextButton.icon(
          onPressed: _busy ? null : _uploadPhoto,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Upload photo'),
        ),
        TextField(
          controller: _firstName,
          decoration: InputDecoration(
            labelText: 'First name',
            errorText: _fieldErrors['first_name'] is List ? _fieldErrors['first_name'][0] : _fieldErrors['first_name']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _lastName,
          decoration: InputDecoration(
            labelText: 'Last name',
            errorText: _fieldErrors['last_name'] is List ? _fieldErrors['last_name'][0] : _fieldErrors['last_name']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _email,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _fieldErrors['email'] is List ? _fieldErrors['email'][0] : _fieldErrors['email']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _goal,
          decoration: InputDecoration(
            labelText: 'Goal',
            errorText: _fieldErrors['goal'] is List ? _fieldErrors['goal'][0] : _fieldErrors['goal']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _dob,
          decoration: InputDecoration(
            labelText: 'DOB YYYY-MM-DD',
            errorText: _fieldErrors['dob'] is List ? _fieldErrors['dob'][0] : _fieldErrors['dob']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _parentMobile,
          decoration: InputDecoration(
            labelText: 'Parent mobile',
            errorText: _fieldErrors['parent_mobile'] is List ? _fieldErrors['parent_mobile'][0] : _fieldErrors['parent_mobile']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _caste,
          decoration: InputDecoration(
            labelText: 'Caste',
            errorText: _fieldErrors['caste'] is List ? _fieldErrors['caste'][0] : _fieldErrors['caste']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _address,
          decoration: InputDecoration(
            labelText: 'Address',
            errorText: _fieldErrors['address'] is List ? _fieldErrors['address'][0] : _fieldErrors['address']?.toString(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save profile'),
        ),
      ],
    );
  }
}
