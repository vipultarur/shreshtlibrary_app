import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/locale_provider.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'package:shreshtlibrary/features/profile/widgets/profile_editor.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/language_selection_screen.dart';
import 'package:shreshtlibrary/features/home/widgets/digital_id_card.dart';
import 'package:shreshtlibrary/common/widgets/restricted_feature_screen.dart';
import 'package:shreshtlibrary/features/profile/widgets/settings_tile.dart';
import 'package:shreshtlibrary/features/profile/widgets/referral_apply_form.dart';
import 'package:shreshtlibrary/common/widgets/status_badge.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';
import 'package:shreshtlibrary/core/theme/theme_provider.dart';
import 'package:shreshtlibrary/core/errors/api_failure.dart';

final profileProvider = StreamProvider.autoDispose<StudentProfile>(
  (ref) => ref.watch(studentApiProvider).profileStream(),
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
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 100,
              ),
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
                    isActive: activeLocale.languageCode == 'en',
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    label: 'हिन्दी',
                    code: 'hi',
                    isActive: activeLocale.languageCode == 'hi',
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    label: 'ગુજરાતી',
                    code: 'gu',
                    isActive: activeLocale.languageCode == 'gu',
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
    required bool isActive,
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
          color: isActive
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
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
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle, color: theme.colorScheme.primary)
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
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'App Theme',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildThemeOption(
                    context,
                    ref,
                    label: 'System Default',
                    mode: ThemeMode.system,
                    isActive: activeTheme == ThemeMode.system,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    ref,
                    label: 'Light',
                    mode: ThemeMode.light,
                    isActive: activeTheme == ThemeMode.light,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    ref,
                    label: 'Dark',
                    mode: ThemeMode.dark,
                    isActive: activeTheme == ThemeMode.dark,
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
    required bool isActive,
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
          color: isActive
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
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
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle, color: theme.colorScheme.primary)
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
          padding: const EdgeInsets.only(right: AppDimensions.spacingMd),
          child: InkWell(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Clear local Hive cache to force fresh server fetch
          final cache = ref.read(localCacheServiceProvider);
          await cache.clearCache('profile');
          await cache.clearCache('idCard');
          await cache.clearCache('referral');
          await cache.clearCache('referralHistory');
          await cache.clearCache('dashboard');
          ref.invalidate(profileProvider);
          ref.invalidate(idCardProvider);
          ref.invalidate(referralProvider);
          ref.invalidate(referralHistoryProvider);
          ref.invalidate(dashboardProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, AppDimensions.spacingMd, 20, 100),
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
                  final isPaymentsRestricted =
                      dash?.restrictedFeatures.contains('payments') ?? false;

                  final isNotificationsRestricted =
                      dash?.restrictedFeatures.contains('notifications') ??
                      false;

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
                        showDivider: false,
                      ),
                    ],
                  );
                },
              ),

              const SectionTitle('App Experience'),
              const ReviewSectionWidget(),
              const SizedBox(height: 24),
              
              // Compact Developer Card
              InkWell(
                onTap: () => context.push('/developer'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.code, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dev_info_title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              l10n.dev_info_app_by + ' ' + l10n.dev_info_name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                    ],
                  ),
                ),
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
    final status =
        dashAsync.value?.membershipStatus ?? l10n.profile_label_loading;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final editBgColor = theme.scaffoldBackgroundColor;

    return AsyncPane(
      value: ref.watch(profileProvider),
      builder: (profile) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.black.withValues(alpha: 0.05),
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
                  image:
                      profile.profilePhoto != null &&
                          profile.profilePhoto!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            profile.profilePhoto!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    profile.profilePhoto == null ||
                        profile.profilePhoto!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 32)
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
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
                      profile.email.isNotEmpty
                          ? profile.email
                          : l10n.profile_no_email,
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: 10,
                  ),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
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
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.spacingSm, bottom: 12, top: AppDimensions.spacingLg),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
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
            color: isDark
                ? Colors.black26
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
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
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
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
    if (_oldPassword.text.isEmpty ||
        _newPassword.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      AppSnackbar.show(context, message: 'Please fill all fields', type: AppSnackbarType.error);
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      AppSnackbar.show(context, message: 'New password and confirm password do not match', type: AppSnackbarType.error);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(studentApiProvider)
          .changePassword(
            oldPassword: _oldPassword.text,
            newPassword: _newPassword.text,
            confirmPassword: _confirmPassword.text,
          );
      if (mounted) {
        AppSnackbar.show(context, message: 'Password changed successfully', type: AppSnackbarType.success);
        context.pop();
      }
    } on ApiFailure catch (e) {
      if (mounted) AppSnackbar.show(context, message: e.message, type: AppSnackbarType.error);
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _busy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Change Password'),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: l10n.profile_tile_id_card),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: DigitalIdCardWidget(),
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
      appBar: CommonAppBar(title: l10n.profile_tile_referrals),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profile_referral_program,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(referralProvider),
              builder: (referral) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profile_your_referral_code,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(referralHistoryProvider),
              builder: (rows) => rows.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surface
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          l10n.profile_no_referral_history,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: rows
                          .map(
                            (row) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
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
  ConsumerState<ReviewSectionWidget> createState() =>
      _ReviewSectionWidgetState();
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
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
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
                          color: isDark
                              ? Colors.amber.shade900.withValues(alpha: 0.3)
                              : Colors.amber.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 32,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Write a Review',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
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
                                  index < selectedRating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: index < selectedRating
                                      ? Colors.amber
                                      : Colors.grey.withValues(alpha: 0.4),
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
                          fillColor: isDark
                              ? Colors.white10
                              : Colors.grey.shade100,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: selectedRating > 0
                                  ? () => Navigator.pop(context, true)
                                  : null,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
        await ref
            .read(studentApiProvider)
            .submitReview(
              rating: selectedRating,
              comment: commentController.text.trim(),
            );
        ref.invalidate(myReviewProvider);
        if (mounted) {
          AppSnackbar.show(
            context, 
            message: 'Review submitted successfully!',
            type: AppSnackbarType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.show(
            context,
            message: 'Failed to submit review',
            type: AppSnackbarType.error,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
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
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
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
            child: Text(
              'Error loading review',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
