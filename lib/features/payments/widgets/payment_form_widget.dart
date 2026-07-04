import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/payments/payments_screen.dart'; // To access providers

class PaymentFormWidget extends ConsumerStatefulWidget {
  const PaymentFormWidget({super.key});

  @override
  ConsumerState<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends ConsumerState<PaymentFormWidget> {
  int? _selectedPlan;
  final _transaction = TextEditingController();
  String _mode = 'UPI';
  bool _busy = false;
  Map<String, dynamic> _fieldErrors = {};
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _transaction.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _transaction.text = response.paymentId ?? '';
    _mode = 'Online';
    _pay();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      showSnack(context, 'Payment Failed: ${response.message}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      showSnack(context, 'External Wallet Selected: ${response.walletName}');
    }
  }

  void _startRazorpay(MembershipPlan plan) {
    final dashboard = ref.read(dashboardProvider).value;
    final rzpKey = dashboard?.razorpayKey;
    if (rzpKey == null || rzpKey.isEmpty) {
      showSnack(context, 'Online payments are currently unavailable.');
      return;
    }

    var options = {
      'key': rzpKey,
      'amount': (plan.price * 100).toInt(),
      'name': 'Shresht Library',
      'description': plan.name,
      'prefill': {
        'contact': '',
        'email': ''
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      if (mounted) showSnack(context, 'Error launching Razorpay.');
    }
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
    return AsyncPane(
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _pay,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Submit Manual'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy || _selectedPlan == null
                      ? null
                      : () {
                          final plan = items.firstWhere(
                              (p) => p.id == _selectedPlan);
                          _startRazorpay(plan);
                        },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Online'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
