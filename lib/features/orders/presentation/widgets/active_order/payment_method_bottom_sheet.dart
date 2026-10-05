import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../app/functions.dart';
import '../../../../../core/constants/assets_manager.dart';
import '../../../../../core/constants/locale_keys.dart';
import '../../../../../core/constants/mosaed_colors.dart';
import '../../../../../core/constants/styles_manager.dart';
import '../../../../../core/widgets/mosaed_price_text.dart';
import '../../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../../../payments/presentation/cubit/payment_cubit.dart';
import '../../../../payments/presentation/payment_checkout_webview.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  const PaymentMethodBottomSheet({
    super.key,
    required this.amount,
    this.paymentRequestId,
    this.bookingId,
    required this.onAfterAction,
    this.enableLoyaltyPoints = false,
  });

  final double amount;
  final String? paymentRequestId;
  final String? bookingId;
  final Future<void> Function() onAfterAction;
  final bool enableLoyaltyPoints;

  static Future<void> show(
    BuildContext context, {
    required double amount,
    String? paymentRequestId,
    String? bookingId,
    required Future<void> Function() onAfterAction,
    bool enableLoyaltyPoints = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => PaymentMethodBottomSheet(
        amount: amount,
        paymentRequestId: paymentRequestId,
        bookingId: bookingId,
        onAfterAction: onAfterAction,
        enableLoyaltyPoints: enableLoyaltyPoints,
      ),
    );
  }

  Future<void> _onMethod(BuildContext context, String method) async {
    final cubit = context.read<PaymentCubit>();
    final updated = await cubit.selectPaymentMethod(
      paymentRequestId: paymentRequestId,
      bookingId: bookingId,
      paymentMethod: method,
    );
    if (!context.mounted || updated == null) return;

    Navigator.of(context).pop();

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

    if (context.mounted) await onAfterAction();
  }

  @override
  Widget build(BuildContext context) {
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

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: MosaedColors.surfaceWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: MosaedColors.fieldBorder,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'mosaedSelectPaymentMethod'.tr(),
                      style: getBoldStyle(
                        fontSize: 18.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: MosaedColors.brandTransparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            ImageAssets.money03,
                            width: 20.w,
                            height: 20.w,
                            colorFilter: const ColorFilter.mode(
                              MosaedColors.brand,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.mosaedCollaborationValue.tr(),
                              style: getMediumStyle(
                                fontSize: 13.sp,
                                color: MosaedColors.brand,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            MosaedPriceText(
                              amount: amount,
                              style: getBoldStyle(
                                fontSize: 16.sp,
                                color: MosaedColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    MosaedPrimaryButton(
                      text: 'mosaedPayOnline'.tr(),
                      isLoading: busy && state is PaymentSelecting,
                      onPressed:
                          busy ? null : () => _onMethod(context, 'online'),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed:
                            busy ? null : () => _onMethod(context, 'cash'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: MosaedColors.brand,
                            width: 1.4,
                          ),
                          foregroundColor: MosaedColors.brand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'mosaedPayCash'.tr(),
                          style: getBoldStyle(
                            fontSize: 16.sp,
                            color: MosaedColors.brand,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
