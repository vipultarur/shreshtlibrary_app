import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppReviewService {
  static const String _keyHasReviewed = 'has_reviewed';
  static const String _keyFirstOpenTime = 'first_open_time';
  static const String _keyLastPromptTime = 'last_review_prompt_time';

  // Android package name or iOS App ID
  // Replace with actual Play Store / App Store link
  static const String _storeUrl = 'https://play.google.com/store/apps/details?id=com.shreshtlibrary.student';

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
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Column(
                children: [
                  Icon(Icons.stars_rounded, size: 48, color: Colors.amber),
                  SizedBox(height: 12),
                  Text(
                    'Enjoying the App?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please take a moment to rate your experience. Your feedback helps us improve!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: selectedRating > 0
                      ? () async {
                          // Mark as reviewed so we don't ask again
                          await prefs.setBool(_keyHasReviewed, true);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          // Redirect to store
                          try {
                            await launchUrlString(_storeUrl, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint('Could not launch store url: $e');
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Review'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
