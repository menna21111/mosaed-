import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/locale_keys.dart';
import '../../../../../core/constants/mosaed_colors.dart';
import '../../../../../core/constants/styles_manager.dart';
import '../../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../models/active_order_view_data.dart';
import '../order_progress_stepper.dart';
import 'active_order_shared.dart';

class ActiveOrderFooter extends StatelessWidget {
  const ActiveOrderFooter({
    super.key,
    required this.data,
    this.confirmingArrival = false,
    this.onConfirmArrival,
    this.onChat,
    this.onReceiveService,
    this.onPay,
    this.onRateTechnician,
  });

  final ActiveOrderViewData data;
  final bool confirmingArrival;
  final VoidCallback? onConfirmArrival;
  final VoidCallback? onChat;
  final VoidCallback? onReceiveService;
  final VoidCallback? onPay;
  final VoidCallback? onRateTechnician;

  @override
  Widget build(BuildContext context) {
    final action = data.progress.primaryAction;
    final showDisclaimer =
        data.showSparePartsDisclaimer && action != ActiveOrderAction.none;

    if (action == ActiveOrderAction.none && !showDisclaimer) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        border: Border(top: BorderSide(color: MosaedColors.fieldBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDisclaimer) ...[
              const ActiveOrderSparePartsBanner(),
              SizedBox(height: 10.h),
            ],
            if (action != ActiveOrderAction.none)
              switch (action) {
                ActiveOrderAction.confirmArrival => MosaedPrimaryButton(
                    text: 'mosaedConfirmProviderArrived'.tr(),
                    isLoading: confirmingArrival,
                    onPressed: onConfirmArrival,
                  ),
                ActiveOrderAction.chat => SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: onChat,
                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 20.sp),
                      label: Text(
                        LocaleKeys.mosaedChatNow.tr(),
                        style: getBoldStyle(
                          fontSize: 14.sp,
                          color: MosaedColors.brand,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: MosaedColors.brand),
                        foregroundColor: MosaedColors.brand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ActiveOrderAction.receiveService => MosaedPrimaryButton(
                    text: LocaleKeys.mosaedReceivedService.tr(),
                    icon: Icons.task_alt_rounded,
                    onPressed: onReceiveService,
                  ),
                ActiveOrderAction.pay => MosaedPrimaryButton(
                    text: LocaleKeys.mosaedPayNow.tr(),
                    icon: Icons.payments_outlined,
                    onPressed: onPay,
                  ),
                ActiveOrderAction.rateTechnician => MosaedPrimaryButton(
                    text: LocaleKeys.mosaedRateTechnician.tr(),
                    icon: Icons.star_outline_rounded,
                    onPressed: onRateTechnician,
                  ),
                ActiveOrderAction.none => const SizedBox.shrink(),
              },
          ],
        ),
      ),
    );
  }
}
