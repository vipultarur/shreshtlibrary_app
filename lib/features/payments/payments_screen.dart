import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/config/app_config.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

final plansProvider = StreamProvider.autoDispose<List<MembershipPlan>>((ref) {
  return ref.watch(studentApiProvider).plansStream();
});
final membershipsProvider = StreamProvider.autoDispose<List<MembershipRecord>>((
  ref,
) {
  return ref.watch(studentApiProvider).membershipsStream();
});
final paymentHistoryProvider = StreamProvider.autoDispose<List<PaymentRecord>>((
  ref,
) {
  return ref.watch(studentApiProvider).paymentHistoryStream();
});

final libraryInfoProvider = StreamProvider.autoDispose<LibraryInfo>((ref) {
  return ref.watch(studentApiProvider).libraryInfoStream();
});

class AvailablePlansWidget extends ConsumerWidget {
  const AvailablePlansWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AsyncPane(
      value: plansAsync,
      builder: (plans) {
        if (plans.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.workspace_premium_outlined,
            title: 'No Plans Available',
            subtitle: 'Check back later for new membership plans.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return FadeInSlide(
              delay: Duration(milliseconds: 50 * index),
              child: InkWell(
                onTap: () async {
                  final libInfo = await ref.read(libraryInfoProvider.future);
                  final phone =
                      libInfo.whatsappNumber ??
                      libInfo.phonePrimary ??
                      'Support';

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final dialogTheme = Theme.of(context);
                        final isDialogDark =
                            dialogTheme.brightness == Brightness.dark;
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
                              color: dialogTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: dialogTheme.colorScheme.primary
                                      .withValues(alpha: 0.15),
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
                                    color: isDialogDark
                                        ? Colors.blue.shade900.withValues(
                                            alpha: 0.3,
                                          )
                                        : Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.support_agent_rounded,
                                    size: 48,
                                    color: isDialogDark
                                        ? Colors.blue.shade300
                                        : Colors.blue.shade600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Activate Plan',
                                  textAlign: TextAlign.center,
                                  style: dialogTheme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'To activate the ${plan.name} plan, please contact us at:',
                                  textAlign: TextAlign.center,
                                  style: dialogTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                        height: 1.5,
                                        color: dialogTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: dialogTheme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SelectableText(
                                    phone,
                                    style: dialogTheme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              dialogTheme.colorScheme.primary,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Got it',
                                      style: TextStyle(
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
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? theme.colorScheme.surface : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${plan.durationMonths} Months',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${plan.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        ),
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
  }
}

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'Memberships & Payments',
      onRefresh: () async {
        ref.invalidate(plansProvider);
        ref.invalidate(membershipsProvider);
        ref.invalidate(paymentHistoryProvider);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncPane(
            value: ref.watch(membershipsProvider),
            builder: (memberships) {
              final activeMemberships = memberships
                  .where((m) => m.status.toLowerCase() == 'active')
                  .toList();

              Widget activePlanWidget = const SizedBox.shrink();
              if (activeMemberships.isNotEmpty) {
                final active = activeMemberships.first;
                activePlanWidget = Column(
                  children: [
                    SectionCard(
                      title: 'Current Active Plan',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.tertiary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Plan',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withValues(alpha: 0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        active.planName.isNotEmpty
                                            ? active.planName
                                            : 'Active Plan',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${active.startDate} to ${active.endDate}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }

              return Column(
                children: [
                  activePlanWidget,
                  const SectionCard(
                    title: 'Available Plans',
                    child: AvailablePlansWidget(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Payment History',
            child: AsyncPane(
              value: ref.watch(paymentHistoryProvider),
              builder: (rows) => rows.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'No payments yet',
                      subtitle: 'Your payment history will appear here.',
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rows.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        final isRefunded =
                            row.status.toLowerCase() == 'refunded';
                        final isSuccess = [
                          'success',
                          'completed',
                          'paid',
                          'verified',
                        ].contains(row.status.toLowerCase());

                        Color statusColor = Colors.orange;
                        IconData statusIcon = Icons.pending;
                        if (isSuccess) {
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                        } else if (isRefunded) {
                          statusColor = Colors.red;
                          statusIcon = Icons.replay_circle_filled;
                        } else if (row.status.toLowerCase() == 'failed') {
                          statusColor = Colors.red;
                          statusIcon = Icons.cancel;
                        }

                        return FadeInSlide(
                          delay: Duration(milliseconds: 50 * index),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.receipt_long,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    row.planName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${row.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: isRefunded
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isRefunded ? Colors.grey : null,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${row.paymentMode} • ${row.paymentDate}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          statusIcon,
                                          size: 12,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          row.status.toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: (isSuccess || isRefunded)
                                ? IconButton(
                                    onPressed: () async {
                                      final tokenStore = ref.read(
                                        tokenStoreProvider,
                                      );
                                      final tokens = await tokenStore.read();
                                      final token = tokens?.access ?? '';

                                      final baseUrl =
                                          AppConfig.apiBaseUrl.endsWith('/')
                                          ? AppConfig.apiBaseUrl.substring(
                                              0,
                                              AppConfig.apiBaseUrl.length - 1,
                                            )
                                          : AppConfig.apiBaseUrl;
                                      final url =
                                          '$baseUrl/payments/${row.id}/receipt?token=$token';
                                      if (await canLaunchUrlString(url)) {
                                        await launchUrlString(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not download receipt',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.download_rounded),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    tooltip: 'Download Receipt',
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
