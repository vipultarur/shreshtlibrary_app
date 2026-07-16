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
    ref.listen<AsyncValue<List<StudentNotification>>>(notificationsProvider, (
      previous,
      next,
    ) {
      if (!next.isLoading && next.hasValue) {
        final notifications = next.value!;
        final promo = notifications.firstWhere(
          (n) =>
              !n.isRead &&
              (n.layout == 'full_image' ||
                  n.layout == 'half_image' ||
                  n.layout == 'background_image'),
          orElse: () => const StudentNotification(
            id: -1,
            title: '',
            body: '',
            isRead: true,
            layout: '',
            type: '',
          ),
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
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 16, right: 16),
                        clipBehavior: Clip.antiAlias,
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
                              color: promo.layout == 'background_image'
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
                              blurRadius: 48,
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            if (promo.layout == 'background_image' &&
                                promo.backgroundImage != null)
                              Positioned.fill(
                                child: Image.network(
                                  promo.backgroundImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            if (promo.layout == 'background_image')
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if ((promo.layout == 'full_image' ||
                                        promo.layout == 'half_image') &&
                                    promo.images.isNotEmpty)
                                  Stack(
                                    children: [
                                      Image.network(
                                        promo.images.first,
                                        width: double.infinity,
                                        height: promo.layout == 'half_image'
                                            ? 160
                                            : 240,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const SizedBox.shrink(),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        height: 40,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                theme.colorScheme.surface
                                                    .withValues(alpha: 0.0),
                                                theme.colorScheme.surface,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        promo.title,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                              color:
                                                  promo.layout ==
                                                      'background_image'
                                                  ? Colors.white
                                                  : theme.colorScheme.onSurface,
                                            ),
                                      ),
                                      if (promo.subtitle != null &&
                                          promo.subtitle!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                promo.layout ==
                                                    'background_image'
                                                ? Colors.amber.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : theme
                                                      .colorScheme
                                                      .primaryContainer
                                                      .withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            promo.subtitle!,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.2,
                                                  color:
                                                      promo.layout ==
                                                          'background_image'
                                                      ? Colors.amber[300]
                                                      : theme
                                                            .colorScheme
                                                            .primary,
                                                ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      Text(
                                        promo.body,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              height: 1.5,
                                              color:
                                                  promo.layout ==
                                                      'background_image'
                                                  ? Colors.white.withValues(
                                                      alpha: 0.9,
                                                    )
                                                  : theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 32),
                                      if (promo.linkUrl != null &&
                                          promo.linkUrl!.isNotEmpty)
                                        SizedBox(
                                          width: double.infinity,
                                          height: 56,
                                          child: FilledButton(
                                            onPressed: () {
                                              _launchUrl(promo.linkUrl!);
                                            },
                                            style: FilledButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation:
                                                  promo.layout ==
                                                      'background_image'
                                                  ? 0
                                                  : 4,
                                              shadowColor: theme
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.4),
                                              backgroundColor:
                                                  promo.layout ==
                                                      'background_image'
                                                  ? Colors.white
                                                  : theme.colorScheme.primary,
                                              foregroundColor:
                                                  promo.layout ==
                                                      'background_image'
                                                  ? Colors.black
                                                  : theme.colorScheme.onPrimary,
                                            ),
                                            child: Text(
                                              promo
                                                          .linkButtonText
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? promo.linkButtonText!
                                                  : 'Explore Now',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                letterSpacing: 0.5,
                                              ),
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
                          color: theme.colorScheme.surface,
                          shape: const CircleBorder(),
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              Navigator.of(context).pop();
                              try {
                                await ref
                                    .read(studentApiProvider)
                                    .markNotificationRead(promo.id);
                                ref.invalidate(notificationsProvider);
                              } catch (e) {
                                debugPrint('Failed to mark read: $e');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
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
    });

    return const SizedBox.shrink();
  }
}
