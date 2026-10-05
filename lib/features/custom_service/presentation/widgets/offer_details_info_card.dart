import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_labeled_row.dart';
import '../../../../core/widgets/mosaed_price_text.dart';
import '../../data/models/custom_service_models.dart';

class OfferDetailsInfoCard extends StatelessWidget {
  const OfferDetailsInfoCard({
    super.key,
    required this.offer,
    this.scheduledLabel,
  });

  final CustomOffer offer;
  final String? scheduledLabel;

  @override
  Widget build(BuildContext context) {
    final notes = offer.note?.trim() ?? '';
    final schedule = scheduledLabel?.trim() ?? '';

    return Container(
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
            svgAsset: ImageAssets.moneyOrderDetails,
            label: LocaleKeys.mosaedPriceOffer.tr(),
            child: MosaedPriceText(
              amount: offer.price,
              style: getBoldStyle(
                fontSize: 16.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: MosaedColors.fieldBorder),
          MosaedLabeledRow(
            svgAsset: ImageAssets.message02,
            label: LocaleKeys.mosaedTechnicianNotes.tr(),
            child: Text(
              notes.isNotEmpty ? notes : '—',
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
                height: 1.5,
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
    );
  }
}
