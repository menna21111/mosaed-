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
import '../../../custom_service/data/models/custom_service_models.dart';
import '../../../orders/presentation/models/active_order_view_data.dart';

class CustomRequestOrderCard extends StatelessWidget {
  const CustomRequestOrderCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final CustomRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = request.title.trim().isNotEmpty
        ? request.title.trim()
        : LocaleKeys.mosaedCustomServiceTitle.tr();
    final description = request.description.trim();
    final relative = ActiveOrderViewData.relativeTimeAgo(request.createdAt);
    final specialization = request.specializationName?.trim() ?? '';
    final offers = request.offersCount ?? 0;
    final showOffers = offers > 0;
    final schedule = (request.scheduledDate == null ||
            request.scheduledDate!.trim().isEmpty)
        ? '—'
        : ActiveOrderViewData.formatScheduleLabel(request.scheduledDate);

    return MosaedRibbonCard(
      statusLabel: request.displayStatusKey.tr(),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: getBoldStyle(
              fontSize: 15.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          if (relative.isNotEmpty) ...[
            SizedBox(height: 6.h),
            MosaedClockLabel(label: relative),
          ],
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description.isNotEmpty) ...[
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          fontSize: 12.sp,
                          color: MosaedColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (specialization.isNotEmpty)
                          MosaedSvgChip(
                            svgAsset: ImageAssets.orders,
                            label: specialization,
                            tintSvg: true,
                          ),
                        MosaedSvgChip(
                          svgAsset: ImageAssets.calendar03,
                          label: schedule,
                          tintSvg: true,
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
                showCountFrom: 2,
              ),
            ],
          ),
          if (showOffers) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: MosaedColors.fieldBorder),
            SizedBox(height: 10.h),
            MosaedOffersCountRow(count: offers),
          ],
        ],
      ),
    );
  }
}
