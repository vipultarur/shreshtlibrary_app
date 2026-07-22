import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/core/config/app_config.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart'; // For notificationsProvider
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard(this.item, {super.key});

  final StudentNotification item;

  Future<void> _markRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(studentApiProvider).markNotificationRead(item.id);
      ref.invalidate(notificationsProvider);
    } on ApiFailure catch (failure) {
      if (context.mounted) AppSnackbar.show(context, message: failure.message, type: AppSnackbarType.error);
    }
  }

  void _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;

    if (url.startsWith('/') &&
        !url.contains('.pdf') &&
        !url.startsWith('/media/')) {
      GoRouter.of(context).push(url);
    } else {
      String finalUrl = url;
      if (url.startsWith('/')) {
        final baseUrl = AppConfig.apiBaseUrl.endsWith('/')
            ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
            : AppConfig.apiBaseUrl;
        finalUrl = '$baseUrl$url';
      }
      if (await canLaunchUrlString(finalUrl)) {
        await launchUrlString(finalUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return DateFormat('h:mm a').format(dateTime);
      }
      return DateFormat('MMM dd, h:mm a').format(dateTime);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUnread = !item.isRead;
    final isDark = theme.brightness == Brightness.dark;

    // Determine styles based on title/type
    IconData icon = Icons.notifications_none_rounded;
    Color iconColor = theme.colorScheme.primary;
    Color bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);

    final titleLower = item.title.toLowerCase();
    final typeLower = item.type.toLowerCase();

    if (typeLower.contains('fee') ||
        typeLower.contains('payment') ||
        titleLower.contains('fee') ||
        titleLower.contains('payment') ||
        titleLower.contains('purchase') ||
        titleLower.contains('off ')) {
      icon = Icons.local_activity_rounded;
      iconColor = isDark ? Colors.redAccent.shade100 : Colors.red.shade500;
      bgColor = isDark
          ? Colors.red.shade900.withValues(alpha: 0.3)
          : Colors.red.shade50;
    } else if (typeLower.contains('attendance') ||
        titleLower.contains('attendance') ||
        titleLower.contains('success')) {
      icon = Icons.chair_alt_rounded;
      iconColor = isDark ? Colors.green.shade300 : Colors.green.shade600;
      bgColor = isDark
          ? Colors.green.shade900.withValues(alpha: 0.3)
          : Colors.green.shade50;
    } else if (typeLower.contains('alert') ||
        typeLower.contains('warning') ||
        titleLower.contains('device') ||
        titleLower.contains('alert') ||
        titleLower.contains('absent') ||
        titleLower.contains('warning')) {
      icon = Icons.priority_high_rounded;
      iconColor = isDark ? Colors.orange.shade300 : Colors.orange.shade600;
      bgColor = isDark
          ? Colors.orange.shade900.withValues(alpha: 0.3)
          : Colors.orange.shade50;
    } else if (typeLower.contains('event') ||
        typeLower.contains('holiday') ||
        titleLower.contains('event') ||
        titleLower.contains('holiday')) {
      icon = Icons.celebration_rounded;
      iconColor = isDark ? Colors.purple.shade300 : Colors.purple.shade600;
      bgColor = isDark
          ? Colors.purple.shade900.withValues(alpha: 0.3)
          : Colors.purple.shade50;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.blue.shade50.withValues(alpha: 0.5))
            : (isDark ? theme.colorScheme.surface : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread
              ? (isDark
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.blue.shade200)
              : theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.5),
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (!isUnread)
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isUnread) _markRead(context, ref);
            context.push('/notifications/${item.id}', extra: item);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Unread Dot
            SizedBox(
              width: 16,
              child: isUnread
                  ? Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 18),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(height: 42),
            ),
            const SizedBox(width: 8),
            // Squircle Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (item.body.isNotEmpty && item.body != item.title) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (item.images.isNotEmpty ||
                      item.backgroundImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.images.isNotEmpty
                            ? item.images.first
                            : item.backgroundImage!,
                        height: item.layout == 'half_image'
                            ? 120
                            : (item.layout == 'background_image' ? 240 : 180),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(item.sentAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
