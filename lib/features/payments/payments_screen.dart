import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

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

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  int? _selectedPlan;
  final _transaction = TextEditingController();
  String _mode = 'UPI';
  bool _busy = false;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void dispose() {
    _transaction.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_selectedPlan == null) {
      showSnack(context, 'Select a membership plan.');
      return;
    }
    setState(() {
      _busy = true;
      _fieldErrors = {};
    });
    try {
      await ref
          .read(studentApiProvider)
          .initiatePayment(
            planId: _selectedPlan!,
            paymentMode: _mode,
            transactionId: _transaction.text.trim(),
          );
      ref.invalidate(paymentHistoryProvider);
      ref.invalidate(membershipsProvider);
      ref.read(notificationServiceProvider).showNotification(
            title: 'Payment Submitted',
            body: 'Your payment has been submitted for verification.',
          );
      if (mounted) {
        _transaction.clear();
        showSnack(context, 'Payment submitted for admin verification.');
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        if (failure.errors is Map<String, dynamic>) {
          setState(() {
            _fieldErrors = failure.errors as Map<String, dynamic>;
          });
        }
        showSnack(context, failure.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
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
          SectionCard(
              title: 'Start Payment',
              child: AsyncPane(
                value: plans,
                builder: (items) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedPlan,
                      items: items
                          .map(
                            (plan) => DropdownMenuItem(
                              value: plan.id,
                              child: Text(
                                '${plan.name} - Rs ${plan.price.toStringAsFixed(2)}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPlan = value),
                      decoration: InputDecoration(
                        labelText: 'Plan',
                        errorText: _fieldErrors['plan_id'] is List ? _fieldErrors['plan_id'][0] : _fieldErrors['plan_id']?.toString(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _mode,
                      items: ['UPI', 'Cash', 'Card', 'Bank Transfer']
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _mode = value ?? 'UPI'),
                      decoration: InputDecoration(
                        labelText: 'Payment mode',
                        errorText: _fieldErrors['payment_mode'] is List ? _fieldErrors['payment_mode'][0] : _fieldErrors['payment_mode']?.toString(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _transaction,
                      decoration: InputDecoration(
                        labelText: 'Transaction ID / UPI reference',
                        errorText: _fieldErrors['transaction_id'] is List ? _fieldErrors['transaction_id'][0] : _fieldErrors['transaction_id']?.toString(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _busy ? null : _pay,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Submit payment'),
                    ),
                  ],
                ),
              ),
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
