import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/theme/app_colors.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart';
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart';
import 'package:shreshtlibrary/common/widgets/restricted_feature_screen.dart';
import 'package:shreshtlibrary/common/widgets/app_image.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final libraryInfoAsync = ref.watch(libraryInfoProvider);
    final logoUrl = libraryInfoAsync.value?.logoSquare;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: AppDimensions.iconXl,
                  height: AppDimensions.iconXl,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: AppDimensions.borderRadiusRound,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: logoUrl != null
                      ? AppImage(
                          urlOrPath: logoUrl,
                          type: AppImageType.network,
                          fit: BoxFit.cover,
                          errorWidget: const AppImage(
                            urlOrPath: 'assets/images/nlogo.png',
                            type: AppImageType.asset,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const AppImage(
                          urlOrPath: 'assets/images/nlogo.png',
                          type: AppImageType.asset,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.app_title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      GestureDetector(
                        onTap: () {
                          launchUrlString(
                            "https://shreshtlibrary.onrender.com/",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Website",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingXs),
                            Icon(
                              Icons.open_in_new,
                              size: AppDimensions.iconSm,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Row(
            children: [
              Container(
                width: AppDimensions.iconXl,
                height: AppDimensions.iconXl,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: AppDimensions.borderRadiusRound,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        final dash = ref.read(dashboardProvider).value;
                        if (dash != null &&
                            dash.restrictedFeatures.contains('notifications')) {
                          showRestrictionDialog(context, dash);
                        } else {
                          context.push('/notifications');
                        }
                      },
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final notificationsAsync = ref.watch(
                          notificationsProvider,
                        );
                        final unreadCount =
                            notificationsAsync.value
                                ?.where((n) => !n.isRead)
                                .length ??
                            0;

                        if (unreadCount == 0) return const SizedBox.shrink();

                        return Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
