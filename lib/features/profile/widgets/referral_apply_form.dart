import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

class ReferralApplyForm extends ConsumerStatefulWidget {
  const ReferralApplyForm({super.key});

  @override
  ConsumerState<ReferralApplyForm> createState() => _ReferralApplyFormState();
}

class _ReferralApplyFormState extends ConsumerState<ReferralApplyForm> {
  final _code = TextEditingController();
  Map<String, dynamic> _fieldErrors = {};

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() => _fieldErrors = {});
    try {
      await ref.read(studentApiProvider).applyReferral(_code.text.trim());
      if (mounted) showSnack(context, 'Referral code is valid.');
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _code,
            decoration: InputDecoration(
              labelText: 'Apply referral code',
              errorText: _fieldErrors['code'] is List ? _fieldErrors['code'][0] : _fieldErrors['code']?.toString(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }
}
