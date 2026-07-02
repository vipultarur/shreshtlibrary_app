import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart';
import 'package:shreshtlibrary/core/services/providers.dart';

class HomeNotificationBanner extends ConsumerWidget {
  const HomeNotificationBanner({super.key});

  void _launchUrl(String url) async {
    if (url.isNotEmpty && await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<StudentNotification>>>(
      notificationsProvider,
      (previous, next) {
        if (!next.isLoading && next.hasValue) {
          final notifications = next.value!;
          final promo = notifications.firstWhere(
            (n) =>
                !n.isRead &&
                (n.layout == 'full_image' || n.layout == 'half_image' || n.layout == 'background_image'),
            orElse: () => const StudentNotification(id: -1, title: '', body: '', isRead: true, layout: ''),
          );

          if (promo.id != -1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.black.withValues(alpha: 0.6),
                builder: (context) {
                  final theme = Theme.of(context);
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(top: 16, right: 16),
                          clipBehavior: Clip.antiAlias,
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Stack(
                            children: [
                              if (promo.layout == 'background_image' && promo.backgroundImage != null)
                                Positioned.fill(
                                  child: Image.network(promo.backgroundImage!,
                                      fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                                ),
                              if (promo.layout == 'background_image')
                                Positioned.fill(
                                  child: Container(color: Colors.black.withValues(alpha: 0.6)),
                                ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if ((promo.layout == 'full_image' || promo.layout == 'half_image') &&
                                      promo.images.isNotEmpty)
                                    Image.network(
                                      promo.images.first,
                                      height: promo.layout == 'half_image' ? 140 : 220,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          promo.title,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: promo.layout == 'background_image'
                                                ? Colors.white
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        if (promo.subtitle != null && promo.subtitle!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            promo.subtitle!,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: promo.layout == 'background_image'
                                                  ? Colors.amber[300]
                                                  : theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        Text(
                                          promo.body,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: promo.layout == 'background_image'
                                                ? Colors.white70
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        if (promo.linkUrl != null && promo.linkUrl!.isNotEmpty)
                                          SizedBox(
                                            width: double.infinity,
                                            child: FilledButton(
                                              onPressed: () {
                                                _launchUrl(promo.linkUrl!);
                                              },
                                              style: FilledButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                backgroundColor: promo.layout == 'background_image'
                                                    ? Colors.white
                                                    : theme.colorScheme.primary,
                                                foregroundColor: promo.layout == 'background_image'
                                                    ? Colors.black
                                                    : theme.colorScheme.onPrimary,
                                              ),
                                              child: Text(
                                                promo.linkButtonText?.isNotEmpty == true
                                                    ? promo.linkButtonText!
                                                    : 'YAY!',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black54),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  await ref.read(studentApiProvider).markNotificationRead(promo.id);
                                  ref.invalidate(notificationsProvider);
                                } catch (e) {
                                  debugPrint('Failed to mark read: $e');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            });
          }
        }
      },
    );

    return const SizedBox.shrink();
  }
}
