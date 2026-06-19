import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

import 'package:shreshtlibrary/features/home/widgets/home_notification_banner.dart';
import 'package:shreshtlibrary/features/home/widgets/home_library_info.dart';
import 'package:shreshtlibrary/features/home/widgets/home_slider.dart';

final dashboardProvider = FutureProvider.autoDispose<StudentDashboard>((ref) {
  return ref.watch(studentApiProvider).dashboard();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _registerFcmToken();
  }

  Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ref.read(studentApiProvider).registerDeviceToken(token);
      }
    } catch (e) {
      debugPrint("Failed to register FCM token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<StudentDashboard>>(
      dashboardProvider,
      (previous, next) {
        if (!next.isLoading && next.hasValue && next.value != null) {
          final dashboard = next.value!;
          if (dashboard.expiryDialogTitle != null && dashboard.expiryDialogMessage != null) {
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [theme.colorScheme.error, theme.colorScheme.errorContainer],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.warning_rounded, size: 64, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      dashboard.expiryDialogTitle!,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      dashboard.expiryDialogMessage!,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.go('/payments');
                                        },
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: theme.colorScheme.primary,
                                        ),
                                        child: const Text(
                                          'Renew Plan',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

    return PageScaffold(
      title: 'Shresht Library',
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final dash = ref.watch(dashboardProvider).value;
            return IconButton(
              onPressed: () {
                if (dash?.restrictedFeatures.contains('notifications') == true) {
                  showSnack(context, 'Notifications restricted to premium members.');
                } else {
                  context.push('/notifications');
                }
              },
              icon: const Icon(Icons.notifications_outlined),
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final dash = ref.watch(dashboardProvider).value;
            return IconButton(
              onPressed: () {
                if (dash?.restrictedFeatures.contains('library') == true) {
                  showSnack(context, 'Library Info restricted to premium members.');
                } else {
                  context.push('/library');
                }
              },
              icon: const Icon(Icons.local_library_outlined),
            );
          },
        ),
      ],
      child: AsyncPane(
        value: ref.watch(dashboardProvider),
        builder: (dashboard) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${dashboard.fullName}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const HomeSliderWidget(),
            const SizedBox(height: 12),

            const HomeLibraryInfoWidget(),
            const HomeNotificationBanner(),
            SectionCard(
              title: 'Today',
              child: Column(
                children: [
                  InfoTile(
                    label: 'Attendance',
                    value: dashboard.markedAttendanceToday ? 'Marked today' : 'Pending today',
                    icon: Icons.fact_check_outlined,
                    iconColor: dashboard.markedAttendanceToday ? Colors.green : Colors.orange,
                  ),
                  InfoTile(
                    label: 'Active plan',
                    value: dashboard.membershipPlan,
                    icon: Icons.card_membership,
                  ),
                  InfoTile(
                    label: 'Days left',
                    value: '${dashboard.membershipDaysLeft}',
                    icon: Icons.calendar_month_outlined,
                  ),
                  InfoTile(
                    label: 'Seat',
                    value: '${dashboard.assignedSeatFloor} / ${dashboard.assignedSeat}',
                    icon: Icons.event_seat_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (dashboard.isHoliday)
                  _ActionChip(
                    label: 'Holiday',
                    icon: Icons.event_busy,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(dashboard.holidayTitle ?? 'Holiday'),
                          content: Text(dashboard.holidayDescription ?? 'Attendance is closed today due to a holiday.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else if (dashboard.membershipStatus == 'LIVE')
                  _ActionChip(
                    label: 'Scan QR',
                    icon: Icons.qr_code_scanner,
                    onTap: () {
                      if (dashboard.restrictedFeatures.contains('attendance')) {
                        showSnack(context, 'Attendance is restricted for non-premium members.');
                      } else {
                        context.push('/attendance/scan');
                      }
                    },
                  ),
                _ActionChip(
                  label: 'Study',
                  icon: Icons.timer_outlined,
                  onTap: () {
                    if (dashboard.restrictedFeatures.contains('study')) {
                      showSnack(context, 'Study tracking is restricted for non-premium members.');
                    } else {
                      context.push('/study');
                    }
                  },
                ),
                _ActionChip(
                  label: 'Plans',
                  icon: Icons.payments_outlined,
                  onTap: () {
                    // Plans should usually be accessible to upgrade
                    context.go('/payments');
                  },
                ),
                _ActionChip(
                  label: 'Profile',
                  icon: Icons.person_outline,
                  onTap: () {
                    if (dashboard.restrictedFeatures.contains('profile')) {
                      showSnack(context, 'Profile is restricted for non-premium members.');
                    } else {
                      context.go('/profile');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
