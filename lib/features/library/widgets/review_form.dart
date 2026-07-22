import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart'; // For reviewsProvider and reviewSummaryProvider
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

class ReviewForm extends ConsumerStatefulWidget {
  const ReviewForm({super.key});

  @override
  ConsumerState<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<ReviewForm> {
  final _comment = TextEditingController();
  int _rating = 5;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _fieldErrors = {});
    try {
      await ref
          .read(studentApiProvider)
          .submitReview(rating: _rating, comment: _comment.text.trim());
      _comment.clear();
      ref.invalidate(reviewsProvider);
      ref.invalidate(reviewSummaryProvider);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.show(context, message: l10n.review_submitted, type: AppSnackbarType.success);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        if (failure.errors is Map<String, dynamic>) {
          setState(() {
            _fieldErrors = failure.errors as Map<String, dynamic>;
          });
        }
        AppSnackbar.show(context, message: failure.message, type: AppSnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _rating,
          items: [1, 2, 3, 4, 5]
              .map(
                (rating) => DropdownMenuItem(
                  value: rating,
                  child: Text(l10n.review_stars(rating)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _rating = value ?? 5),
          decoration: InputDecoration(
            labelText: l10n.review_label_rating,
            errorText: _fieldErrors['rating'] is List
                ? _fieldErrors['rating'][0]
                : _fieldErrors['rating']?.toString(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _comment,
          decoration: InputDecoration(
            labelText: l10n.review_label_review,
            errorText: _fieldErrors['comment'] is List
                ? _fieldErrors['comment'][0]
                : _fieldErrors['comment']?.toString(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _submit,
            child: Text(l10n.review_btn_submit),
          ),
        ),
      ],
    );
  }
}
