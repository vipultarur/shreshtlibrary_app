import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/status_badge.dart';

class HomeGreetingStatus extends ConsumerWidget {
  const HomeGreetingStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: dashboardAsync.when(
        data: (dashboard) {
          String status =
              dashboard.attendanceStatus ??
              (dashboard.markedAttendanceToday ? 'Present' : 'Pending');
          if (dashboard.isHoliday) status = 'Holiday';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreetingMessage(l10n),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      dashboard.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(
                    status: status,
                    time: status.toLowerCase() == 'absent'
                        ? null
                        : dashboard.attendanceTime,
                  ),
                ],
              ),
              if (dashboard.membershipStatus == 'PENDING') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.orange.shade900.withValues(alpha: 0.3)
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.orange.shade700
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        color: isDark
                            ? Colors.orange.shade300
                            : Colors.orange.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.home_pending_activation,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.orange.shade200
                                    : Colors.orange.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.home_pending_activation_desc,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.orange.shade100
                                    : Colors.orange.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.push('/payments'),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.orange.shade900
                              : Colors.orange.shade100,
                          foregroundColor: isDark
                              ? Colors.orange.shade50
                              : Colors.orange.shade900,
                        ),
                        child: Text(l10n.home_plans),
                      ),
                    ],
                  ),
                ),
              ] else if (dashboard.membershipStatus == 'SUSPENDED') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.pink.shade900.withValues(alpha: 0.3)
                        : Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.pink.shade700
                          : Colors.pink.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.block,
                        color: isDark
                            ? Colors.pink.shade300
                            : Colors.pink.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.expiryDialogTitle ??
                                  l10n.home_account_suspended,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.pink.shade200
                                    : Colors.pink.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dashboard.expiryDialogMessage ??
                                  l10n.home_account_suspended_desc,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.pink.shade100
                                    : Colors.pink.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (dashboard.membershipStatus == 'EXPIRED') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.shade900.withValues(alpha: 0.3)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.red.shade700 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: isDark
                            ? Colors.red.shade400
                            : Colors.red.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.expiryDialogTitle ??
                                  l10n.home_membership_expired,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.red.shade200
                                    : Colors.red.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dashboard.expiryDialogMessage ??
                                  l10n.home_membership_expired_desc,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.red.shade100
                                    : Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.push('/payments'),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.red.shade900
                              : Colors.red.shade100,
                          foregroundColor: isDark
                              ? Colors.red.shade50
                              : Colors.red.shade900,
                        ),
                        child: Text(l10n.home_renew),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => Shimmer.fromColors(
          baseColor: Colors.black12,
          highlightColor: Colors.white24,
          child: Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        error: (err, stack) => Text(l10n.home_failed_load_user),
      ),
    );
  }
  String _getGreetingMessage(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.home_good_morning;
    } else if (hour < 17) {
      return l10n.home_good_afternoon;
    } else {
      return l10n.home_good_evening;
    }
  }
}
