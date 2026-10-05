import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../data/completion_form_model.dart';

/// Progress stages for an active order after a technician is assigned.
enum ActiveOrderStage { arrival, execution, handover, payment, rating }

class ActiveOrderProgress {
  const ActiveOrderProgress({
    this.completion,
    this.customerRating = 0,
    this.hasAssignedProvider = true,
    this.awaitingPrice = false,
    this.canConfirmArrival = true,
  });

  final CompletionForm? completion;
  final double customerRating;
  final bool hasAssignedProvider;
  final bool awaitingPrice;

  /// Catalog (existed) bookings only confirm arrival after status is completed.
  final bool canConfirmArrival;

  static const stepCount = 4;

  bool get hasRated => customerRating > 0;

  /// الطلب لم يُسند لفني بعد — لا نعرض تأكيد الوصول ولا خطوات التنفيذ.
  bool get isAwaitingProvider =>
      !hasAssignedProvider &&
      (completion == null || !completion!.hasStarted);

  bool get isAwaitingPrice => awaitingPrice;

  bool get showStepper =>
      hasAssignedProvider && !isAwaitingProvider && !isAwaitingPrice;

  bool get needsRating {
    final c = completion;
    if (c == null || !c.hasFinished || hasRated) return false;
    if (c.isAwaitingCashPayment) return false;
    return c.isPaymentPaid ||
        c.isAwaitingGatewayPayment ||
        (!c.needsPaymentMethodChoice && c.hasPaymentRequest);
  }

  bool get isRatingPhase {
    final c = completion;
    if (c == null || !c.hasFinished) return false;
    if (hasRated) return false;
    return c.isAwaitingCashPayment || needsRating;
  }

  int get completedStepIndex {
    if (isAwaitingProvider) return -1;
    final c = completion;
    if (c == null || c.needsArrivalConfirm || !c.hasStarted) return -1;
    if (c.isPaymentPaid || hasRated) return 3;
    if (c.hasFinished) return 2;
    if (c.hasAfterImage) return 1;
    return 0;
  }

  int get activeStepIndex {
    if (isAwaitingProvider) return -1;
    final c = completion;
    if (c == null || c.needsArrivalConfirm || !c.hasStarted) return 0;
    if (c.isPaymentPaid || hasRated) return -1;
    if (!c.hasFinished) {
      if (c.hasAfterImage) return 2;
      return 1;
    }
    return 3;
  }

  bool get showWorkPhotos {
    final c = completion;
    return c != null && (c.hasBeforeImage || c.hasAfterImage);
  }

  bool get isInProgress =>
      completion != null && completion!.hasStarted && !completion!.hasFinished;

  ActiveOrderAction get primaryAction {
    final c = completion;
    if (isAwaitingProvider || isAwaitingPrice) return ActiveOrderAction.none;
    if (c == null || c.needsArrivalConfirm) {
      return canConfirmArrival
          ? ActiveOrderAction.confirmArrival
          : ActiveOrderAction.chat;
    }
    if (needsRating) return ActiveOrderAction.rateTechnician;
    if (c.hasFinished) {
      if (c.isPaymentPaid || c.isAwaitingCashPayment) {
        return ActiveOrderAction.none;
      }
      if (c.canShowPayment && !c.isPaymentPaid) {
        return ActiveOrderAction.pay;
      }
      return ActiveOrderAction.none;
    }
    if (c.hasAfterImage) return ActiveOrderAction.receiveService;
    return ActiveOrderAction.chat;
  }
}

enum ActiveOrderAction {
  confirmArrival,
  chat,
  receiveService,
  pay,
  rateTechnician,
  none,
}

class OrderProgressStepper extends StatelessWidget {
  const OrderProgressStepper({
    super.key,
    required this.progress,
  });

  final ActiveOrderProgress progress;

  static const _steps = [
    LocaleKeys.mosaedStepArrival,
    LocaleKeys.mosaedStepExecution,
    LocaleKeys.mosaedStepHandover,
    LocaleKeys.mosaedStepPayment,
  ];

  static const _doneColor = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    final completed = progress.completedStepIndex;
    final active = progress.activeStepIndex;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.fieldBorder),
        boxShadow: MosaedColors.softShadow,
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final lineDone =
                stepBefore < active || (active < 0 && stepBefore <= completed);
            final lineActive =
                stepBefore == active - 1 || stepBefore <= completed;
            return Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.only(bottom: 18.h),
                color: lineDone
                    ? _doneColor
                    : lineActive
                        ? MosaedColors.brand
                        : const Color(0xFFE5E7EB),
              ),
            );
          }

          final step = index ~/ 2;
          final isDone = step <= completed;
          final isActive = step == active;
          return _StepNode(
            label: _steps[step].tr(),
            isDone: isDone,
            isActive: isActive,
          );
        }),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final String label;
  final bool isDone;
  final bool isActive;

  static const _doneColor = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    final Color ring;
    final Color fill;
    final Color labelColor;
    final Color iconColor;

    if (isDone) {
      ring = _doneColor;
      fill = _doneColor;
      labelColor = _doneColor;
      iconColor = Colors.white;
    } else if (isActive) {
      ring = MosaedColors.brand;
      fill = MosaedColors.brand;
      labelColor = MosaedColors.brand;
      iconColor = Colors.white;
    } else {
      ring = const Color(0xFFD1D5DB);
      fill = const Color(0xFFF3F4F6);
      labelColor = MosaedColors.textHint;
      iconColor = const Color(0xFF9CA3AF);
    }

    return SizedBox(
      width: 56.w,
      child: Column(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 1.5),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              ImageAssets.checkmarkCircle03,
              width: 14.w,
              height: 14.w,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getMediumStyle(fontSize: 11.sp, color: labelColor),
          ),
        ],
      ),
    );
  }
}
