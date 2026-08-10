import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../data/models/payment_request.dart';
import 'widgets/payment_method_choice_panel.dart';
import 'widgets/payment_status_section.dart';

/// شاشة الدفع: إما حالة جاهزة من الـ API أو اختيار ثابت بعد انتهاء الخدمة.
class PaymentFlowScreen extends StatefulWidget {
  const PaymentFlowScreen({
    super.key,
    required this.loadPayment,
    required this.onFinished,
    required this.fallbackAmount,
    this.serviceFinished = true,
  });

  final Future<PaymentRequest?> Function() loadPayment;
  final Future<void> Function() onFinished;
  final double fallbackAmount;
  final bool serviceFinished;

  @override
  State<PaymentFlowScreen> createState() => _PaymentFlowScreenState();
}

class _PaymentFlowScreenState extends State<PaymentFlowScreen> {
  PaymentRequest? _payment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final payment = await widget.loadPayment();
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() async {
    await widget.onFinished();
    final payment = await widget.loadPayment();
    if (!mounted) return;
    setState(() => _payment = payment ?? _payment);
  }

  bool get _showStaticChoices =>
      widget.serviceFinished &&
      (_payment == null || _payment!.isAwaitingMethod);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'mosaedSelectPaymentMethod'.tr(),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: MosaedColors.primaryContainer,
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: MosaedColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    if (_payment != null && !_payment!.isAwaitingMethod) ...[
                      PaymentStatusSection(
                        payment: _payment!,
                        enableLoyaltyPoints: true,
                        onRefresh: _onRefresh,
                      ),
                    ] else if (_showStaticChoices) ...[
                      PaymentMethodChoicePanel(
                        paymentRequestId: _payment?.id,
                        amount: _payment?.payableAmount ??
                            _payment?.amount ??
                            widget.fallbackAmount,
                        enableLoyaltyPoints: true,
                        onAfterAction: widget.onFinished,
                      ),
                    ] else if (_payment != null)
                      PaymentStatusSection(
                        payment: _payment!,
                        enableLoyaltyPoints: true,
                        onRefresh: _onRefresh,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
