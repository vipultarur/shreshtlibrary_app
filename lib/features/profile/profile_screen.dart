import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'package:shreshtlibrary/features/profile/widgets/profile_editor.dart';
import 'package:shreshtlibrary/features/profile/widgets/referral_apply_form.dart';

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
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBB9FF),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => context.push('/study'),
                          icon: const Icon(Icons.timer_outlined, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                          icon: const Icon(Icons.logout, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(profileProvider);
                    ref.invalidate(idCardProvider);
                    ref.invalidate(referralProvider);
                    ref.invalidate(referralHistoryProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AsyncPane(
                          value: ref.watch(profileProvider),
                          builder: (profile) => ProfileEditor(profile: profile),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? Colors.grey.shade100 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _selectedTab == 0 ? Colors.transparent : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'ID Card',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTab == 0 ? Colors.black87 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? Colors.grey.shade100 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _selectedTab == 1 ? Colors.transparent : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Referrals',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTab == 1 ? Colors.black87 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (_selectedTab == 0) ...[
                          const Text('Digital ID Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          AsyncPane(
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
                        ] else ...[
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

