import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/config/app_config.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

class NotificationDetailsScreen extends ConsumerWidget {
  const NotificationDetailsScreen({
    super.key,
    this.id,
    this.notification,
  });

  final String? id;
  final StudentNotification? notification;

  void _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    
    if (url.startsWith('/') && !url.contains('.pdf') && !url.startsWith('/media/')) {
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
      return DateFormat('MMMM dd, yyyy \u2022 h:mm a').format(dateTime);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (notification == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Details')),
        body: const Center(child: Text('Notification not found')),
      );
    }

    final item = notification!;

    IconData icon = Icons.notifications_none_rounded;
    Color iconColor = theme.colorScheme.primary;
    Color bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);

    final titleLower = item.title.toLowerCase();
    final typeLower = item.type.toLowerCase();
    
    if (typeLower.contains('fee') || typeLower.contains('payment') || titleLower.contains('fee') || titleLower.contains('payment') || titleLower.contains('purchase') || titleLower.contains('off ')) {
      icon = Icons.local_activity_rounded;
      iconColor = isDark ? Colors.redAccent.shade100 : Colors.red.shade500;
      bgColor = isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50;
    } else if (typeLower.contains('attendance') || titleLower.contains('attendance') || titleLower.contains('success')) {
      icon = Icons.chair_alt_rounded;
      iconColor = isDark ? Colors.green.shade300 : Colors.green.shade600;
      bgColor = isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50;
    } else if (typeLower.contains('alert') || typeLower.contains('warning') || titleLower.contains('device') || titleLower.contains('alert') || titleLower.contains('absent') || titleLower.contains('warning')) {
      icon = Icons.priority_high_rounded;
      iconColor = isDark ? Colors.orange.shade300 : Colors.orange.shade600;
      bgColor = isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50;
    } else if (typeLower.contains('event') || typeLower.contains('holiday') || titleLower.contains('event') || titleLower.contains('holiday')) {
      icon = Icons.celebration_rounded;
      iconColor = isDark ? Colors.purple.shade300 : Colors.purple.shade600;
      bgColor = isDark ? Colors.purple.shade900.withValues(alpha: 0.3) : Colors.purple.shade50;
    }

    return Scaffold(
      appBar: const CommonAppBar(title: 'Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? theme.colorScheme.surface : theme.colorScheme.surface,
                    bgColor.withValues(alpha: isDark ? 0.2 : 0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(item.sentAt),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if ((item.body.isNotEmpty && item.body != item.title) || (item.description != null && item.description!.isNotEmpty))
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.body.isNotEmpty && item.body != item.title) ...[
                            Text(
                              item.body,
                              style: theme.textTheme.titleMedium?.copyWith(
                                height: 1.6,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (item.description != null && item.description!.isNotEmpty)
                            Text(
                              item.description!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  if (item.images.isNotEmpty || item.backgroundImage != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: item.images.isNotEmpty ? item.images.first : item.backgroundImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  if (item.images.length > 1) ...[
                    ...item.images.skip(1).map((imgUrl) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          ),
                        ),
                      ),
                    )),
                  ],

                  if (item.linkUrl != null && item.linkUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _launchUrl(context, item.linkUrl!),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(
                        item.linkButtonText?.isNotEmpty == true 
                            ? item.linkButtonText! 
                            : 'Open Link',
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
