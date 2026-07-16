import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppReviewService {
  static const String _keyHasReviewed = 'has_reviewed';
  static const String _keyFirstOpenTime = 'first_open_time';
  static const String _keyLastPromptTime = 'last_review_prompt_time';

  // Android package name or iOS App ID
  // Replace with actual Play Store / App Store link
  static const String _storeUrl =
      'https://play.google.com/store/apps/details?id=com.shreshtlibrary.student';

  static Future<void> checkAndShowReviewDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final bool hasReviewed = prefs.getBool(_keyHasReviewed) ?? false;
    if (hasReviewed) return;

    final int firstOpen = prefs.getInt(_keyFirstOpenTime) ?? 0;
    final now = DateTime.now();

    if (firstOpen == 0) {
      // First time opening the app, record the time
      await prefs.setInt(_keyFirstOpenTime, now.millisecondsSinceEpoch);
      return;
    }

    final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpen);

    // Check if 1 day has passed since first open
    if (now.difference(firstOpenDate).inDays >= 1) {
      final int lastPrompt = prefs.getInt(_keyLastPromptTime) ?? 0;

      if (lastPrompt == 0) {
        // Never prompted before, but 1 day has passed
        if (context.mounted) {
          _showReviewDialog(context, prefs);
        }
      } else {
        // Prompted before, check if 2 days have passed since last prompt
        final lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPrompt);
        if (now.difference(lastPromptDate).inDays >= 2) {
          if (context.mounted) {
            _showReviewDialog(context, prefs);
          }
        }
      }
    }
  }

  static void _showReviewDialog(BuildContext context, SharedPreferences prefs) {
    // Record that we are prompting now
    prefs.setInt(_keyLastPromptTime, DateTime.now().millisecondsSinceEpoch);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int selectedRating = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 48,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.shade900.withValues(alpha: 0.3)
                            : Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        size: 32,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enjoying the App?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please take a moment to rate your experience. Your feedback helps us improve!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                index < selectedRating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: index < selectedRating
                                    ? Colors.amber
                                    : Colors.grey.withValues(alpha: 0.4),
                                size: 40,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Not Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: selectedRating > 0
                                ? () async {
                                    await prefs.setBool(_keyHasReviewed, true);
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                    try {
                                      await launchUrlString(
                                        _storeUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (e) {
                                      debugPrint(
                                        'Could not launch store url: $e',
                                      );
                                    }
                                  }
                                : null,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
