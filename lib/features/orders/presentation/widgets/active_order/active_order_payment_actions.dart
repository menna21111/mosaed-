import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../../app/functions.dart';
import '../../../../../core/constants/mosaed_colors.dart';
import '../../../../payments/presentation/cubit/payment_cubit.dart';
import '../../../../payments/presentation/payment_checkout_webview.dart';
import '../../../data/completion_form_model.dart';
import '../order_progress_stepper.dart';
import 'payment_method_bottom_sheet.dart';

class ActiveOrderPaymentActions {
  const ActiveOrderPaymentActions({
    required this.completion,
    required this.amount,
    this.paymentRequestId,
    this.bookingId,
    required this.onRefresh,
    this.enableLoyaltyPoints = false,
    this.paymentSectionKey,
  });

  final CompletionForm? completion;
  final double amount;
  final String? paymentRequestId;
  final String? bookingId;
  final Future<void> Function() onRefresh;
  final bool enableLoyaltyPoints;
  final GlobalKey? paymentSectionKey;

  Future<void> handlePayTap(BuildContext context) async {
    final c = completion;
    if (c == null) {
      _scrollToPayment();
      return;
    }

    if (c.isAwaitingGatewayPayment) {
      final id = c.paymentRequestId?.trim() ?? paymentRequestId?.trim() ?? '';
      if (id.isEmpty) {
        AppFunctions.showsToast(
          'mosaedPaymentNotReady'.tr(),
          MosaedColors.brand,
          context,
        );
        return;
      }
      final cubit = context.read<PaymentCubit>();
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
      if (context.mounted) await onRefresh();
      return;
    }

    if (c.needsPaymentMethodChoice || c.isAwaitingPaymentCreation) {
      final id = c.paymentRequestId?.trim() ?? paymentRequestId?.trim();
      if (id == null || id.isEmpty) {
        AppFunctions.showsToast(
          'mosaedPaymentNotReady'.tr(),
          MosaedColors.brand,
          context,
        );
        await onRefresh();
        return;
      }
      await PaymentMethodBottomSheet.show(
        context,
        amount: amount,
        paymentRequestId: id,
        bookingId: bookingId,
        onAfterAction: onRefresh,
        enableLoyaltyPoints: enableLoyaltyPoints,
      );
      return;
    }

    _scrollToPayment();
  }

  void _scrollToPayment() {
    final ctx = paymentSectionKey?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }
}

extension ActiveOrderProgressPayment on ActiveOrderProgress {
  String? get statusBannerKey {
    if (isAwaitingProvider) return 'mosaedWorkerPending';
    final c = completion;
    if (c == null) return null;
    if (c.isAwaitingCashPayment) return 'mosaedPaymentAwaitingProviderCash';
    if (c.isAwaitingGatewayPayment) return 'mosaedPaymentCompleteOnline';
    if (c.isAwaitingPaymentCreation) return 'mosaedPaymentPreparingHint';
    return null;
  }

  bool get hidePayButton {
    final c = completion;
    if (c == null) return false;
    return c.isAwaitingCashPayment || c.isPaymentPaid;
  }
}
