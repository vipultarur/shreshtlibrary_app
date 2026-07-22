import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/theme/theme_provider.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/notifications_enabled_provider.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'package:shreshtlibrary/features/profile/widgets/settings_tile.dart';
import 'package:shreshtlibrary/features/profile/widgets/language_picker_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      // ignore
    }
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_logout),
        content: Text(l10n.settings_logout_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settings_logout_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(l10n.settings_logout_yes),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    // Check if notifications are disabled globally for this student
    final dashboardState = ref.watch(dashboardProvider);
    final isNotificationsRestricted = dashboardState.maybeWhen(
      data: (data) => data.restrictedFeatures.contains('notifications'),
      orElse: () => true,
    );

    return PageScaffold(
      title: l10n.settings_title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        SettingsGroupWidget(
          title: l10n.settings_general,
          child: Column(
            children: [
              SettingsTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: l10n.settings_theme,
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).setTheme(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.language,
                title: l10n.profile_language,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const LanguagePickerSheet(),
                  );
                },
              ),
            ],
          ),
        ),
        
        if (!isNotificationsRestricted)
          SettingsGroupWidget(
            title: l10n.profile_tile_notifications,
            child: Column(
              children: [
                SettingsTile(
                  icon: ref.watch(notificationsEnabledProvider)
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  title: l10n.profile_tile_notifications,
                  trailing: Switch(
                    value: ref.watch(notificationsEnabledProvider),
                    onChanged: (value) {
                      ref.read(notificationsEnabledProvider.notifier).setEnabled(value);
                    },
                  ),
                  onTap: () {
                    final isEnabled = ref.read(notificationsEnabledProvider);
                    ref.read(notificationsEnabledProvider.notifier).setEnabled(!isEnabled);
                  },
                ),
              ],
            ),
          ),

        SettingsGroupWidget(
          title: l10n.settings_information,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settings_privacy_policy,
                onTap: () => context.push('/privacy-policy'),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.settings_instructions,
                onTap: () => context.push('/instructions'),
              ),
              SettingsTile(
                icon: Icons.code,
                title: l10n.settings_developer_info,
                onTap: () => context.push('/developer'),
              ),
            ],
          ),
        ),

        SettingsGroupWidget(
          title: l10n.profile_section_account,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.logout,
                title: l10n.settings_logout,
                isDestructive: true,
                showDivider: false,
                onTap: () => _showLogoutDialog(context, l10n),
              ),
            ],
          ),
        ),

        if (_appVersion.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                '${l10n.settings_app_version} $_appVersion',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
      ],
      ),
    );
  }
}

class SettingsGroupWidget extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsGroupWidget({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.8) : theme.colorScheme.primary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
