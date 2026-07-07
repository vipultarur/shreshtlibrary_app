import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'package:shreshtlibrary/features/profile/widgets/profile_editor.dart';
import 'package:shreshtlibrary/features/profile/widgets/referral_apply_form.dart';
import 'package:shreshtlibrary/common/widgets/status_badge.dart';

final profileProvider = FutureProvider.autoDispose<StudentProfile>(
  (ref) => ref.watch(studentApiProvider).profile(),
);
final idCardProvider = FutureProvider.autoDispose<StudentIdCard>(
  (ref) => ref.watch(studentApiProvider).idCard(),
);
final referralProvider = FutureProvider.autoDispose<ReferralCode>(
  (ref) => ref.watch(studentApiProvider).referralCode(),
);
final referralHistoryProvider =
    FutureProvider.autoDispose<List<ReferralHistory>>(
      (ref) => ref.watch(studentApiProvider).referralHistory(),
    );

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: CommonAppBar(
        title: 'Profile',
        rightIcon: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: () {}, // Action for more
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.more_horiz, color: textColor, size: 20),
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
              
              const SectionTitle('Account'),
              SectionCard(
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Account Information',
                    onTap: () => context.push('/profile/account'),
                  ),
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'Digital ID Card',
                    onTap: () => context.push('/profile/id-card'),
                    showDivider: false,
                  ),
                ],
              ),

              const SectionTitle('Accounts & Subscription'),
              SectionCard(
                children: [
                  SettingsTile(
                    icon: Icons.payment_outlined,
                    title: 'My Payments',
                    onTap: () => context.push('/payments'),
                  ),
                  SettingsTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                      activeThumbColor: const Color(0xFF917CFF),
                    ),
                    onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
                    showDivider: false,
                  ),
                ],
              ),

              const SectionTitle('Settings'),
              SectionCard(
                children: [
                  SettingsTile(
                    icon: Icons.logout,
                    title: 'Logout',
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
    final dashAsync = ref.watch(dashboardProvider);
    final status = dashAsync.value?.membershipStatus ?? 'Loading...';
    
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
                          image: CachedNetworkImageProvider(profile.profilePhoto!),
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
                      profile.email.isNotEmpty ? profile.email : 'No email provided',
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
                        'Edit',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Account Information'),
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

class IdCardScreen extends ConsumerWidget {
  const IdCardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Digital ID Card'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AsyncPane(
          value: ref.watch(idCardProvider),
          builder: (card) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                InfoTile(
                  label: 'Name',
                  value: card.fullName,
                  icon: Icons.badge_outlined,
                ),
                InfoTile(
                  label: 'Mobile',
                  value: card.mobile,
                  icon: Icons.phone_outlined,
                ),
                InfoTile(
                  label: 'Goal',
                  value: card.goal,
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2, size: 24, color: Colors.black54),
                      const SizedBox(width: 8),
                      SelectableText(
                        card.qrData,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Referrals', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Referral Program', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(referralProvider),
              builder: (referral) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF140C2C), Color(0xFF2C1B54)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Referral Code',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
                      'Used by ${referral.usedByCount} students',
                      style: const TextStyle(color: Color(0xFFCBB9FF), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const ReferralApplyForm(),
            const SizedBox(height: 24),
            const Text(
              'Referral History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(referralHistoryProvider),
              builder: (rows) => rows.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text('No referral history yet.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : Column(
                      children: rows
                          .map(
                            (row) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
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


