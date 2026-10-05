import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_meta_bits.dart';
import '../../../../core/widgets/mosaed_photo_thumb.dart';
import '../../../../core/widgets/mosaed_ribbon_card.dart';
import '../../../../core/widgets/mosaed_svg_chip.dart';
import '../../../orders/presentation/models/active_order_view_data.dart';
import '../../data/models/custom_service_models.dart';

class CustomRequestSummaryCard extends StatelessWidget {
  const CustomRequestSummaryCard({super.key, required this.request});

  final CustomRequest request;

  @override
  Widget build(BuildContext context) {
    final specialization = request.specializationName?.trim() ?? '';
    final schedule =
        ActiveOrderViewData.formatScheduleLabel(request.scheduledDate);
    final dayLabel = ActiveOrderViewData.relativeDayLabel(request.createdAt);

    return MosaedRibbonCard(
      statusLabel: request.displayStatusKey.tr(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title.trim().isNotEmpty
                      ? request.title.trim()
                      : LocaleKeys.mosaedCustomServiceTitle.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getBoldStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                MosaedClockLabel(label: dayLabel, iconSize: 14, fontSize: 12),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (specialization.isNotEmpty)
                      MosaedSvgChip(
                        svgAsset: ImageAssets.orders,
                        label: specialization,
                        tintSvg: true,
                        labelColor: MosaedColors.brand,
                      ),
                    MosaedSvgChip(
                      svgAsset: ImageAssets.calendar03,
                      label: schedule,
                      tintSvg: true,
                      labelColor: MosaedColors.brand,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          MosaedPhotoThumb(
            cover: request.coverImage,
            photoCount: request.allImages.length,
          ),
        ],
      ),
    );
  }
}
