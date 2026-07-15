import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/locale_provider.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'package:shreshtlibrary/features/profile/widgets/profile_editor.dart';
import 'package:shreshtlibrary/common/widgets/restricted_feature_screen.dart';
import 'package:shreshtlibrary/features/profile/widgets/referral_apply_form.dart';
import 'package:shreshtlibrary/common/widgets/status_badge.dart';
import 'package:shreshtlibrary/core/theme/theme_provider.dart';
import 'package:shreshtlibrary/core/errors/api_failure.dart';

final profileProvider = StreamProvider.autoDispose<StudentProfile>(
  (ref) => ref.watch(studentApiProvider).profileStream(),
);
final idCardProvider = StreamProvider.autoDispose<StudentIdCard>(
  (ref) => ref.watch(studentApiProvider).idCardStream(),
);
final referralProvider = StreamProvider.autoDispose<ReferralCode>(
  (ref) => ref.watch(studentApiProvider).referralCodeStream(),
);
final referralHistoryProvider =
    StreamProvider.autoDispose<List<ReferralHistory>>(
      (ref) => ref.watch(studentApiProvider).referralHistoryStream(),
    );

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी';
      case 'gu':
        return 'ગુજરાતી';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final activeLocale = ref.watch(localeProvider);
            final l10n = AppLocalizations.of(context)!;
            
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.profile_select_language,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildLanguageOption(
                    context, 
                    ref, 
                    label: 'English', 
                    code: 'en', 
                    isActive: activeLocale.languageCode == 'en'
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context, 
                    ref, 
                    label: 'हिन्दी', 
                    code: 'hi', 
                    isActive: activeLocale.languageCode == 'hi'
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context, 
                    ref, 
                    label: 'ગુજરાતી', 
                    code: 'gu', 
                    isActive: activeLocale.languageCode == 'gu'
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, 
    WidgetRef ref, {
    required String label, 
    required String code, 
    required bool isActive
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.dividerColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            else
              const SizedBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System Default';
    }
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final activeTheme = ref.watch(themeModeProvider);
            
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'App Theme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildThemeOption(
                    context, 
                    ref, 
                    label: 'System Default', 
                    mode: ThemeMode.system, 
                    isActive: activeTheme == ThemeMode.system
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context, 
                    ref, 
                    label: 'Light', 
                    mode: ThemeMode.light, 
                    isActive: activeTheme == ThemeMode.light
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context, 
                    ref, 
                    label: 'Dark', 
                    mode: ThemeMode.dark, 
                    isActive: activeTheme == ThemeMode.dark
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, 
    WidgetRef ref, {
    required String label, 
    required ThemeMode mode, 
    required bool isActive
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setTheme(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.dividerColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            else
              const SizedBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: CommonAppBar(
        title: l10n.profile_title,
        rightIcon: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(idCardProvider);
          ref.invalidate(referralProvider);
          ref.invalidate(referralHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileSummaryCard(),
              
              SectionTitle(l10n.profile_section_account),
              SectionCard(
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: l10n.profile_tile_info,
                    onTap: () => context.push('/profile/account'),
                  ),
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: l10n.profile_tile_id_card,
                    onTap: () => context.push('/profile/id-card'),
                    showDivider: false,
                  ),
                ],
              ),

              SectionTitle(l10n.profile_section_subscription),
              Consumer(
                builder: (context, ref, _) {
                  final dash = ref.watch(dashboardProvider).value;
                  final isPaymentsRestricted = dash?.restrictedFeatures.contains('payments') ?? false;

                  final isNotificationsRestricted = dash?.restrictedFeatures.contains('notifications') ?? false;

                  return SectionCard(
                    children: [
                      SettingsTile(
                        icon: Icons.payment_outlined,
                        title: l10n.profile_tile_payments,
                        onTap: () {
                          if (isPaymentsRestricted && dash != null) {
                            showRestrictionDialog(context, dash);
                          } else {
                            context.push('/payments');
                          }
                        },
                      ),
                      SettingsTile(
                        icon: Icons.notifications_none,
                        title: l10n.profile_tile_notifications,
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (val) {
                            if (isNotificationsRestricted && dash != null) {
                              showRestrictionDialog(context, dash);
                            } else {
                              setState(() => _notificationsEnabled = val);
                            }
                          },
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                        onTap: () {
                          if (isNotificationsRestricted && dash != null) {
                            showRestrictionDialog(context, dash);
                          } else {
                            setState(() => _notificationsEnabled = !_notificationsEnabled);
                          }
                        },
                        showDivider: false,
                      ),
                    ],
                  );
                },
              ),

              const SectionTitle('App Experience'),
              const ReviewSectionWidget(),

              SectionTitle(l10n.profile_settings),
              SectionCard(
                children: [
                  SettingsTile(
                    icon: Icons.brightness_6_outlined,
                    title: 'App Theme',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getThemeName(themeMode),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    onTap: () => _showThemePicker(context),
                  ),
                  SettingsTile(
                    icon: Icons.language,
                    title: l10n.profile_language,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getLanguageName(locale.languageCode),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    onTap: () => _showLanguagePicker(context),
                  ),
                  SettingsTile(
                    icon: Icons.logout,
                    title: l10n.profile_tile_logout,
                    onTap: () => ref.read(authControllerProvider.notifier).logout(),
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    showDivider: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSummaryCard extends ConsumerWidget {
  const ProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashAsync = ref.watch(dashboardProvider);
    final status = dashAsync.value?.membershipStatus ?? l10n.profile_label_loading;
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final editBgColor = theme.scaffoldBackgroundColor;

    return AsyncPane(
      value: ref.watch(profileProvider),
      builder: (profile) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  image: profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            profile.profilePhoto!,
                            errorListener: (err) => debugPrint('Image error: $err'),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile.profilePhoto == null || profile.profilePhoto!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email.isNotEmpty ? profile.email : l10n.profile_no_email,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: status, time: null),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push('/profile/account'),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: editBgColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: textColor),
                      const SizedBox(width: 6),
                      Text(
                        l10n.profile_edit_btn,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 24),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final List<Widget> children;
  const SectionCard({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color? iconColor;
  final Color? textColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final iconBgColor = theme.scaffoldBackgroundColor;
    final dividerColor = theme.dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor ?? defaultTextColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? defaultTextColor),
                  ),
                ),
                if (trailing != null) trailing!
                else Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 60, right: 16),
              child: Divider(height: 1, color: dividerColor),
            ),
        ],
      ),
    );
  }
}



// Sub-screens for Account Navigation

class AccountInfoScreen extends ConsumerWidget {
  const AccountInfoScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: l10n.profile_tile_info,
        rightIcon: IconButton(
          icon: const Icon(Icons.lock_reset),
          tooltip: 'Change Password',
          onPressed: () => context.push('/profile/change-password'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AsyncPane(
          value: ref.watch(profileProvider),
          builder: (profile) => ProfileEditor(profile: profile),
        ),
      ),
    );
  }
}


class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_oldPassword.text.isEmpty || _newPassword.text.isEmpty || _confirmPassword.text.isEmpty) {
      showSnack(context, 'Please fill all fields');
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      showSnack(context, 'New password and confirm password do not match');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(studentApiProvider).changePassword(
        oldPassword: _oldPassword.text,
        newPassword: _newPassword.text,
        confirmPassword: _confirmPassword.text,
      );
      if (mounted) {
        showSnack(context, 'Password changed successfully');
        context.pop();
      }
    } on ApiFailure catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: 'Change Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _oldPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Old Password',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}


class IdCardScreen extends ConsumerWidget {
  const IdCardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: l10n.profile_tile_id_card),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AsyncPane(
          value: ref.watch(idCardProvider),
          builder: (card) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                InfoTile(
                  label: l10n.profile_label_name,
                  value: card.fullName,
                  icon: Icons.badge_outlined,
                ),
                InfoTile(
                  label: l10n.profile_label_mobile,
                  value: card.mobile,
                  icon: Icons.phone_outlined,
                ),
                InfoTile(
                  label: l10n.profile_label_goal,
                  value: card.goal,
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2, size: 24, color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      SelectableText(
                        card.qrData,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color),
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

class ReferralsScreen extends ConsumerWidget {
  const ReferralsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: l10n.profile_tile_referrals,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profile_referral_program, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(referralProvider),
              builder: (referral) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profile_your_referral_code,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      referral.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.profile_referral_used_by(referral.usedByCount),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const ReferralApplyForm(),
            const SizedBox(height: 24),
            Text(
              l10n.profile_referral_history,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(referralHistoryProvider),
              builder: (rows) => rows.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(l10n.profile_no_referral_history, style: const TextStyle(color: Colors.grey)),
                      ),
                    )
                  : Column(
                      children: rows
                          .map(
                            (row) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: InfoTile(
                                label: row.appliedAt,
                                value: row.referredStudentName,
                                icon: Icons.person_add_outlined,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewSectionWidget extends ConsumerStatefulWidget {
  const ReviewSectionWidget({super.key});

  @override
  ConsumerState<ReviewSectionWidget> createState() => _ReviewSectionWidgetState();
}

class _ReviewSectionWidgetState extends ConsumerState<ReviewSectionWidget> {
  Future<void> _showReviewDialog() async {
    int selectedRating = 0;
    final commentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(28),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 48,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, size: 40, color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Write a Review',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'How would you rate your experience?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: index < selectedRating ? Colors.amber : Colors.grey.withValues(alpha: 0.4),
                                size: 40,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: selectedRating > 0 ? () => Navigator.pop(context, true) : null,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      try {
        await ref.read(studentApiProvider).submitReview(
              rating: selectedRating,
              comment: commentController.text.trim(),
            );
        ref.invalidate(myReviewProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myReviewAsync = ref.watch(myReviewProvider);

    return SectionCard(
      children: [
        myReviewAsync.when(
          data: (review) {
            if (review != null && review.id > 0) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Review',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                    if (review.comment.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.comment,
                        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      review.isApproved ?? false ? 'Status: Approved' : 'Status: Pending Approval',
                      style: TextStyle(
                        fontSize: 12,
                        color: review.isApproved ?? false ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              );
            }
            return SettingsTile(
              icon: Icons.star_rate_rounded,
              title: 'Write a Review',
              onTap: _showReviewDialog,
              showDivider: false,
              iconColor: Colors.amber,
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading review', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ),
      ],
    );
  }
}


