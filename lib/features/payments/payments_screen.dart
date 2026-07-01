import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/payments/widgets/payment_form_widget.dart';

final plansProvider = FutureProvider.autoDispose<List<MembershipPlan>>((ref) {
  return ref.watch(studentApiProvider).plans();
});
final membershipsProvider = FutureProvider.autoDispose<List<MembershipRecord>>((
  ref,
) {
  return ref.watch(studentApiProvider).memberships();
});
final paymentHistoryProvider = FutureProvider.autoDispose<List<PaymentRecord>>((
  ref,
) {
  return ref.watch(studentApiProvider).paymentHistory();
});

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
          const SectionCard(
            title: 'Start Payment',
            child: PaymentFormWidget(),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Membership History',
            child: AsyncPane(
              value: ref.watch(membershipsProvider),
              builder: (rows) => rows.isEmpty
                  ? const Text('No memberships yet.')
                  : Column(
                      children: rows
                          .map(
                            (row) => InfoTile(
                              label: '${row.startDate} to ${row.endDate}',
                              value: '${row.planName} (${row.status})',
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Payment History',
            child: AsyncPane(
              value: ref.watch(paymentHistoryProvider),
              builder: (rows) => rows.isEmpty
                  ? const Text('No payments yet.')
                  : Column(
                      children: rows
                          .map(
                            (row) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.receipt_long_outlined,
                              ),
                              title: Text(
                                '${row.planName} - Rs ${row.amount.toStringAsFixed(2)}',
                              ),
                              subtitle: Text(
                                '${row.paymentMode} / ${row.paymentDate}',
                              ),
                              trailing: Text(row.status),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
