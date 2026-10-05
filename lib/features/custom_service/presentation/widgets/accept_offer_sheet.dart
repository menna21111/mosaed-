import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_labeled_row.dart';
import '../../../../core/widgets/mosaed_price_text.dart';
import '../../../../core/widgets/mosaed_svg_chip.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../data/models/custom_service_models.dart';

class AcceptOfferSheet extends StatelessWidget {
  const AcceptOfferSheet({
    super.key,
    required this.offer,
    this.requestTitle,
    this.scheduledLabel,
  });

  final CustomOffer offer;
  final String? requestTitle;
  final String? scheduledLabel;

  static Future<bool?> show(
    BuildContext context, {
    required CustomOffer offer,
    String? requestTitle,
    String? scheduledLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => AcceptOfferSheet(
        offer: offer,
        requestTitle: requestTitle,
        scheduledLabel: scheduledLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerName = offer.providerName?.trim().isNotEmpty == true
        ? offer.providerName!
        : 'mosaedWorkerPending'.tr();
    final title = requestTitle?.trim().isNotEmpty == true
        ? requestTitle!.trim()
        : LocaleKeys.mosaedCustomServiceTitle.tr();
    final schedule = scheduledLabel?.trim() ?? '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
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
                  LocaleKeys.mosaedConfirmAcceptOffer.tr(),
                  style: getBoldStyle(
                    fontSize: 18.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                MosaedSvgChip(
                  svgAsset: ImageAssets.tag02,
                  label: title,
                  labelColor: MosaedColors.brand,
                  maxLabelWidth: 240,
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: MosaedColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: MosaedColors.fieldBorder),
                  ),
                  child: Column(
                    children: [
                      MosaedLabeledRow(
                        svgAsset: ImageAssets.userIconProfile,
                        label: LocaleKeys.mosaedTechnician.tr(),
                        child: Text(
                          providerName,
                          style: getMediumStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: MosaedColors.fieldBorder),
                      MosaedLabeledRow(
                        svgAsset: ImageAssets.moneyOrderDetails,
                        label: LocaleKeys.mosaedPriceOffer.tr(),
                        child: MosaedPriceText(
                          amount: offer.price,
                          style: getMediumStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: MosaedColors.fieldBorder),
                      MosaedLabeledRow(
                        svgAsset: ImageAssets.time04,
                        label: LocaleKeys.mosaedAppointment.tr(),
                        child: Text(
                          schedule.isNotEmpty ? schedule : '—',
                          style: getMediumStyle(
                            fontSize: 14.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  LocaleKeys.mosaedAfterAcceptDisclaimer.tr(),
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 18.h),
                MosaedPrimaryButton(
                  text: LocaleKeys.mosaedConfirmAcceptance.tr(),
                  onPressed: () => Navigator.pop(context, true),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'cancel'.tr(),
                      style: getMediumStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.textSecondary,
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
  }
}
