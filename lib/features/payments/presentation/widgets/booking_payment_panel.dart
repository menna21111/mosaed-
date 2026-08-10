import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../app/functions.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../cubit/payment_cubit.dart';
import '../payment_checkout_webview.dart';

/// Existed-service payment after `is_finished`.
///
/// Uses `payment_request_id` from completion only — then:
/// `POST /api/payments/<payment_request_id>/select-method/`
class BookingPaymentPanel extends StatelessWidget {
  const BookingPaymentPanel({
    super.key,
    required this.paymentRequestId,
    this.paymentStatus,
    required this.amount,
    required this.onAfterAction,
  });

  /// From completion: `payment_request_id`.
  final String paymentRequestId;
  final String? paymentStatus;
  final double amount;
  final Future<void> Function() onAfterAction;

  bool get _awaitingOnline {
    final s = (paymentStatus ?? '').toLowerCase().trim();
    return s.contains('awaiting_gateway') ||
        s.contains('awaiting_online') ||
        s.contains('gateway');
  }

  bool get _awaitingCash {
    final s = (paymentStatus ?? '').toLowerCase().trim();
    return s.contains('awaiting_cash') || s.contains('cash_confirmation');
  }

  Future<void> _onSelectMethod(BuildContext context, String method) async {
    final id = paymentRequestId.trim();
    if (id.isEmpty) {
      AppFunctions.showsToast(
        'تعذر العثور على طلب الدفع',
        MosaedColors.danger,
        context,
      );
      return;
    }

    final cubit = context.read<PaymentCubit>();
    final updated = await cubit.selectPaymentMethod(
      paymentRequestId: id,
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
      final url = await cubit.buildOnlinePaymentUrl(id);
      if (!context.mounted) return;
      await Navigator.of(context).push<bool?>(
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: PaymentCheckoutWebView(
            checkoutUrl: url,
            paymentRequestId: id,
          ),
        ),
      );
    }

    if (context.mounted) await onAfterAction();
  }

  Future<void> _openOnlineCheckout(BuildContext context) async {
    final id = paymentRequestId.trim();
    if (id.isEmpty) {
      AppFunctions.showsToast(
        'تعذر العثور على طلب الدفع',
        MosaedColors.danger,
        context,
      );
      return;
    }

    final cubit = context.read<PaymentCubit>();
    final url = await cubit.buildOnlinePaymentUrl(id);
    if (!context.mounted) return;

    final result = await Navigator.of(context).push<bool?>(
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: PaymentCheckoutWebView(
          checkoutUrl: url,
          paymentRequestId: id,
        ),
      ),
    );

    if (!context.mounted) return;
    await onAfterAction();

    if (!context.mounted) return;
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
  }

  @override
  Widget build(BuildContext context) {
    final currency = 'mosaedCurrency'.tr();
    final showAmount = amount > 0;

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
        final busy = state is PaymentSelecting;

        if (_awaitingCash) {
          return _shell(
            statusLabel: 'mosaedPaymentStatusAwaitingCash'.tr(),
            amountLabel: showAmount
                ? '${amount.toStringAsFixed(0)} $currency'
                : 'mosaedPriceSetByDashboard'.tr(),
            child: _infoBanner(
              icon: Icons.hourglass_top_rounded,
              text: 'mosaedPaymentAwaitingProviderCash'.tr(),
              color: const Color(0xFFF59E0B),
            ),
          );
        }

        if (_awaitingOnline) {
          return _shell(
            statusLabel: 'mosaedPaymentStatusAwaitingOnline'.tr(),
            amountLabel: showAmount
                ? '${amount.toStringAsFixed(0)} $currency'
                : 'mosaedPriceSetByDashboard'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'mosaedPaymentCompleteOnline'.tr(),
                  style: getMediumStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14.h),
                MosaedPrimaryButton(
                  text: 'mosaedOpenPaymentPage'.tr(),
                  icon: Icons.open_in_new_rounded,
                  isLoading: busy,
                  onPressed:
                      busy ? null : () => _openOnlineCheckout(context),
                ),
              ],
            ),
          );
        }

        return _shell(
          statusLabel: 'mosaedPaymentStatusSelectMethod'.tr(),
          amountLabel: showAmount
              ? '${amount.toStringAsFixed(0)} $currency'
              : 'mosaedPriceSetByDashboard'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                isLoading: busy,
                onPressed:
                    busy ? null : () => _onSelectMethod(context, 'online'),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton.icon(
                  onPressed:
                      busy ? null : () => _onSelectMethod(context, 'cash'),
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

  Widget _shell({
    required String statusLabel,
    required String amountLabel,
    required Widget child,
  }) {
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
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: MosaedColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusLabel,
                  style: getMediumStyle(
                    fontSize: 11.sp,
                    color: MosaedColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            amountLabel,
            style: getBoldStyle(
              fontSize: amount > 0 ? 24.sp : 14.sp,
              color: MosaedColors.primary,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
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
