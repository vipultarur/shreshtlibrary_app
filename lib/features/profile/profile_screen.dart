import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          onPressed: () => context.push('/study'),
          icon: const Icon(Icons.timer_outlined),
        ),
        IconButton(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      onRefresh: () async {
        ref.invalidate(profileProvider);
        ref.invalidate(idCardProvider);
        ref.invalidate(referralProvider);
        ref.invalidate(referralHistoryProvider);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
              title: 'Student Profile',
              child: AsyncPane(
                value: ref.watch(profileProvider),
                builder: (profile) => ProfileEditor(profile: profile),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'ID Card',
              child: AsyncPane(
                value: ref.watch(idCardProvider),
                builder: (card) => Column(
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
                    SelectableText(card.qrData),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Referral',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AsyncPane(
                    value: ref.watch(referralProvider),
                    builder: (referral) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          referral.code,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text('Used by ${referral.usedByCount} students'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ReferralApplyForm(),
                  const SizedBox(height: 12),
                  AsyncPane(
                    value: ref.watch(referralHistoryProvider),
                    builder: (rows) => rows.isEmpty
                        ? const Text('No referral history yet.')
                        : Column(
                            children: rows
                                .map(
                                  (row) => InfoTile(
                                    label: row.appliedAt,
                                    value: row.referredStudentName,
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

