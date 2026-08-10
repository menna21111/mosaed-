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

/// أزرار أونلاين / كاش — تظهر لما لسه مختارش طريقة دفع.
class PaymentMethodChoicePanel extends StatefulWidget {
  const PaymentMethodChoicePanel({
    super.key,
    this.paymentRequestId,
    this.bookingId,
    required this.onAfterAction,
    required this.amount,
    this.title,
    this.enableLoyaltyPoints = false,
  });

  /// من completion.payment_request_id أو من تفاصيل الدفع.
  final String? paymentRequestId;

  /// للحجز: fallback لو payment_request_id فاضي.
  final String? bookingId;

  final Future<void> Function() onAfterAction;
  final double amount;
  final String? title;

  /// Custom requests only — show apply/remove points before method choice.
  final bool enableLoyaltyPoints;

  @override
  State<PaymentMethodChoicePanel> createState() =>
      _PaymentMethodChoicePanelState();
}

class _PaymentMethodChoicePanelState extends State<PaymentMethodChoicePanel> {
  PaymentRequest? _payment;
  late double _displayAmount;

  @override
  void initState() {
    super.initState();
    _displayAmount = widget.amount;
  }

  @override
  void didUpdateWidget(covariant PaymentMethodChoicePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount && _payment == null) {
      _displayAmount = widget.amount;
    }
  }

  Future<void> _onMethod(BuildContext context, String method) async {
    final cubit = context.read<PaymentCubit>();

    final updated = await cubit.selectPaymentMethod(
      paymentRequestId: widget.paymentRequestId,
      bookingId: widget.bookingId,
      paymentMethod: method,
    );
    if (!context.mounted || updated == null) return;

    AppFunctions.showsToast(
      method == 'cash'
          ? 'mosaedPaymentCashSelected'.tr()
          : 'mosaedPaymentOnlineSelected'.tr(),
      MosaedColors.success,
      context,
    );

    if (method == 'online' || updated.isAwaitingOnlinePayment) {
      final url = await cubit.buildOnlinePaymentUrl(updated.id);
      if (!context.mounted) return;
      await Navigator.of(context).push<bool?>(
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: PaymentCheckoutWebView(
            checkoutUrl: url,
            paymentRequestId: updated.id,
          ),
        ),
      );
    }

    if (context.mounted) await widget.onAfterAction();
  }

  @override
  Widget build(BuildContext context) {
    final currency = 'mosaedCurrency'.tr();
    final paymentId = widget.paymentRequestId?.trim() ?? '';
    final showPoints =
        widget.enableLoyaltyPoints && paymentId.isNotEmpty;

    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentFailure) {
          AppFunctions.showsToast(
            state.message,
            MosaedColors.danger,
            context,
          );
        }
      },
      builder: (context, state) {
        final busy = state is PaymentSelecting || state is PaymentPointsBusy;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: MosaedColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: MosaedColors.border),
            boxShadow: MosaedColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ?? 'mosaedPaymentInfo'.tr(),
                style: getBoldStyle(
                  fontSize: 15.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '${_displayAmount.toStringAsFixed(0)} $currency',
                style: getBoldStyle(
                  fontSize: 24.sp,
                  color: MosaedColors.primary,
                ),
              ),
              if (_payment?.hasPointsApplied == true) ...[
                SizedBox(height: 4.h),
                Text(
                  '${'mosaedOriginalAmount'.tr()}: ${widget.amount.toStringAsFixed(0)} $currency',
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
              ],
              if (showPoints) ...[
                SizedBox(height: 14.h),
                PaymentPointsSection(
                  paymentRequestId: paymentId,
                  baseAmount: widget.amount,
                  initialPayment: _payment,
                  onPaymentUpdated: (updated) {
                    setState(() {
                      _payment = updated;
                      _displayAmount =
                          updated?.payableAmount ?? widget.amount;
                    });
                  },
                ),
              ],
              SizedBox(height: 12.h),
              Text(
                'mosaedSelectPaymentMethod'.tr(),
                style: getMediumStyle(
                  fontSize: 13.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              MosaedPrimaryButton(
                text: 'mosaedPayOnline'.tr(),
                icon: Icons.credit_card_rounded,
                isLoading: busy && state is PaymentSelecting,
                onPressed: busy ? null : () => _onMethod(context, 'online'),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => _onMethod(context, 'cash'),
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
          ),
        );
      },
    );
  }
}
