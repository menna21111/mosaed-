import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../app/functions.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../data/models/payment_request.dart';
import '../cubit/payment_cubit.dart';
import '../payment_checkout_webview.dart';
import 'payment_points_section.dart';

/// Customer payment: select method → cash wait / online WebView.
class PaymentStatusSection extends StatefulWidget {
  const PaymentStatusSection({
    super.key,
    required this.payment,
    required this.onRefresh,
    this.enableLoyaltyPoints = false,
  });

  final PaymentRequest payment;
  final Future<void> Function() onRefresh;

  /// Custom requests only — apply/remove points while awaiting payment.
  final bool enableLoyaltyPoints;

  @override
  State<PaymentStatusSection> createState() => _PaymentStatusSectionState();
}

class _PaymentStatusSectionState extends State<PaymentStatusSection> {
  bool _openingOnline = false;
  late PaymentRequest _payment;

  PaymentRequest get payment => _payment;
  String get _currency => 'mosaedCurrency'.tr();

  @override
  void initState() {
    super.initState();
    _payment = widget.payment;
  }

  @override
  void didUpdateWidget(covariant PaymentStatusSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payment.id != widget.payment.id ||
        oldWidget.payment.status != widget.payment.status ||
        oldWidget.payment.finalAmount != widget.payment.finalAmount ||
        oldWidget.payment.pointsUsed != widget.payment.pointsUsed) {
      _payment = widget.payment;
    }
  }

  bool get _canUsePoints =>
      widget.enableLoyaltyPoints &&
      payment.id.trim().isNotEmpty &&
      !payment.isPaid;

  Future<void> _selectMethod(String method) async {
    final cubit = context.read<PaymentCubit>();
    final updated = await cubit.selectPaymentMethod(
      paymentRequestId: payment.id,
      paymentMethod: method,
    );
    if (!mounted || updated == null) return;

    setState(() => _payment = updated);

    AppFunctions.showsToast(
      method == 'cash'
          ? 'mosaedPaymentCashSelected'.tr()
          : 'mosaedPaymentOnlineSelected'.tr(),
      MosaedColors.success,
      context,
    );
    if (method == 'online' ||
        updated.isOnline ||
        updated.isAwaitingOnlinePayment) {
      await _openOnlineCheckout(updated.id);
    } else {
      await widget.onRefresh();
    }
  }

  Future<void> _openOnlineCheckout([String? paymentId]) async {
    setState(() => _openingOnline = true);
    try {
      final cubit = context.read<PaymentCubit>();
      final id = paymentId ?? payment.id;
      final url = await cubit.buildOnlinePaymentUrl(id);
      if (!mounted) return;

      final result = await Navigator.of(context).push<bool?>(
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: PaymentCheckoutWebView(
            checkoutUrl: url,
            paymentRequestId: id,
          ),
        ),
      );

      if (!mounted) return;
      await widget.onRefresh();

      if (!mounted) return;
      if (result == true) {
        AppFunctions.showsToast(
          'mosaedPaymentStatusPaid'.tr(),
          MosaedColors.success,
          context,
        );
      } else if (result == false) {
        AppFunctions.showsToast(
          'mosaedPaymentFailed'.tr(),
          MosaedColors.danger,
          context,
        );
      }
    } catch (_) {
      if (mounted) {
        AppFunctions.showsToast(
          'mosaedPaymentOpenFailed'.tr(),
          MosaedColors.danger,
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _openingOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = payment.payableAmount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: payment.isPaid ? MosaedColors.success : MosaedColors.border,
        ),
        boxShadow: MosaedColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_rounded,
                color: MosaedColors.primary,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'mosaedPaymentInfo'.tr(),
                  style: getBoldStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  payment.statusKey.tr(),
                  style: getMediumStyle(fontSize: 11.sp, color: _statusColor),
                ),
              ),
            ],
          ),
          if (payment.requestTitle?.trim().isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Text(
              payment.requestTitle!,
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Text(
            '${displayAmount.toStringAsFixed(0)} $_currency',
            style: getBoldStyle(fontSize: 24.sp, color: MosaedColors.primary),
          ),
          if (payment.hasPointsApplied) ...[
            SizedBox(height: 4.h),
            Text(
              '${'mosaedOriginalAmount'.tr()}: ${payment.amount.toStringAsFixed(0)} $_currency',
              style: getRegularStyle(
                fontSize: 12.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          ],
          if (_canUsePoints) ...[
            SizedBox(height: 14.h),
            PaymentPointsSection(
              paymentRequestId: payment.id,
              baseAmount: payment.amount,
              initialPayment: payment,
              onPaymentUpdated: (updated) {
                if (updated == null) return;
                setState(() => _payment = updated);
              },
            ),
          ],
          SizedBox(height: 16.h),
          if (payment.isPaid)
            _infoBanner(
              icon: Icons.check_circle_outline_rounded,
              text: 'mosaedPaymentStatusPaid'.tr(),
              color: MosaedColors.success,
            )
          else if (payment.isAwaitingMethod) ...[
            Text(
              'mosaedSelectPaymentMethod'.tr(),
              style: getMediumStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, state) {
                final selecting = state is PaymentSelecting ||
                    state is PaymentPointsBusy;
                return Column(
                  children: [
                    MosaedPrimaryButton(
                      text: 'mosaedPayOnline'.tr(),
                      icon: Icons.credit_card_rounded,
                      isLoading: state is PaymentSelecting,
                      onPressed:
                          selecting ? null : () => _selectMethod('online'),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: OutlinedButton.icon(
                        onPressed:
                            selecting ? null : () => _selectMethod('cash'),
                        icon: Icon(
                          Icons.payments_outlined,
                          color: MosaedColors.primary,
                          size: 20.sp,
                        ),
                        label: Text(
                          'mosaedPayCash'.tr(),
                          style: getBoldStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: MosaedColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else if (payment.isAwaitingCashConfirmation)
            _infoBanner(
              icon: Icons.hourglass_top_rounded,
              text: 'mosaedPaymentAwaitingProviderCash'.tr(),
              color: const Color(0xFFF59E0B),
            )
          else if (payment.isAwaitingOnlinePayment) ...[
            _infoBanner(
              icon: Icons.credit_card_rounded,
              text: 'mosaedPaymentCompleteOnline'.tr(),
              color: MosaedColors.primary,
            ),
            SizedBox(height: 12.h),
            MosaedPrimaryButton(
              text: 'mosaedOpenPaymentPage'.tr(),
              icon: Icons.open_in_new_rounded,
              isLoading: _openingOnline,
              onPressed: _openingOnline ? null : () => _openOnlineCheckout(),
            ),
          ] else
            _infoBanner(
              icon: Icons.info_outline_rounded,
              text: payment.statusKey.tr(),
              color: MosaedColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Color get _statusColor {
    if (payment.isPaid) return MosaedColors.success;
    if (payment.isAwaitingCashConfirmation) return const Color(0xFFF59E0B);
    if (payment.isAwaitingOnlinePayment || payment.isAwaitingMethod) {
      return MosaedColors.primary;
    }
    return MosaedColors.textSecondary;
  }

  Widget _infoBanner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: getMediumStyle(fontSize: 13.sp, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
