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
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No plans available at the moment.', textAlign: TextAlign.center),
          );
        }
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return InkWell(
              onTap: () async {
                final libInfo = await ref.read(libraryInfoProvider.future);
                final phone = libInfo.whatsappNumber ?? libInfo.phonePrimary ?? 'Support';
                
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Activate Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('To activate the ${plan.name} plan, please contact us at:\n\n$phone', style: const TextStyle(fontSize: 16)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.white24 : theme.colorScheme.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.workspace_premium, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Duration: ${plan.durationMonths} Months', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('₹${plan.price.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            );
          },
        );
      }
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Plan',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        active.planName.isNotEmpty ? active.planName : 'Active Plan',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
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
                                Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8), size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  '${active.startDate} to ${active.endDate}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
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
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No payments yet.', textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rows.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        final isRefunded = row.status.toLowerCase() == 'refunded';
                        final isSuccess = ['success', 'completed', 'paid', 'verified'].contains(row.status.toLowerCase());
                        
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
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  row.planName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${row.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: isRefunded ? TextDecoration.lineThrough : null,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      Icon(statusIcon, size: 12, color: statusColor),
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
                                    final tokenStore = ref.read(tokenStoreProvider);
                                    final tokens = await tokenStore.read();
                                    final token = tokens?.access ?? '';

                                    final baseUrl = AppConfig.apiBaseUrl.endsWith('/') 
                                        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1) 
                                        : AppConfig.apiBaseUrl;
                                    final url = '$baseUrl/payments/${row.id}/receipt?token=$token';
                                    if (await canLaunchUrlString(url)) {
                                      await launchUrlString(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not download receipt')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.download_rounded),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Download Receipt',
                                )
                              : null,
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

