import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/common/widgets/action_button_purple.dart';

class HomeFloatingAction extends ConsumerWidget {
  const HomeFloatingAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dash = ref.watch(dashboardProvider).value;
    final isHoliday = dash?.isHoliday ?? false;

    if (isHoliday) {
      return ActionButtonPurple(
        label: l10n.home_holiday,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
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
                  padding: const EdgeInsets.all(24),
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
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
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
                              ? Colors.purple.shade900.withValues(alpha: 0.3)
                              : Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.celebration_rounded,
                          color: isDark
                              ? Colors.purple.shade300
                              : Colors.purple.shade600,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        dash?.holidayTitle ?? l10n.home_holiday,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dash?.holidayDescription ?? l10n.home_holiday_desc,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.home_ok,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

    bool isRestricted =
        dash != null && dash.restrictedFeatures.contains('attendance');
    bool isScanActive = dash != null && dash.allowQrScan;

    if (isRestricted || !isScanActive) {
      return const SizedBox.shrink();
    }

    return ActionButtonPurple(
      label: l10n.home_scan,
      icon: Icons.qr_code_scanner,
      onTap: () {
        context.push('/attendance/scan');
      },
    );
  }
}
