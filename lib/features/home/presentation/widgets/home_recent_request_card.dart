import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_meta_bits.dart';
import '../../../../core/widgets/mosaed_network_avatar.dart';
import '../../../../core/widgets/mosaed_price_text.dart';
import '../../../../core/widgets/mosaed_ribbon_card.dart';
import '../../../custom_service/data/models/custom_service_models.dart';

class HomeRecentRequestCard extends StatelessWidget {
  const HomeRecentRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final CustomRequest request;
  final VoidCallback onTap;

  String? _dateLabel(BuildContext context) {
    final raw = request.scheduledDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    return DateFormat('d MMMM y', context.locale.toString()).format(dt);
  }

  double? get _price {
    final price = request.acceptedOffer?.price;
    if (price == null || price <= 0) return null;
    return price;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateLabel(context);
    final price = _price;
    final specialization = request.specializationName?.trim();

    return MosaedRibbonCard(
      statusLabel: request.displayStatusKey.tr(),
      onTap: onTap,
      width: 300.w,
      height: 120.h,
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Row(
            children: [
              MosaedNetworkAvatar(
                url: request.coverImage,
                size: 40,
                fallbackIcon: Icons.handyman_rounded,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getSemiBoldStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    if (specialization != null && specialization.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FB),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          specialization,
                          style: getRegularStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF4A7AB5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (dateLabel != null || price != null) ...[
            Divider(height: 1, color: MosaedColors.fieldBorder),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (dateLabel != null)
                  Expanded(
                    child: MosaedSvgLabel(
                      asset: ImageAssets.calendar03,
                      label: dateLabel,
                      fontSize: 11,
                    ),
                  ),
                if (dateLabel != null && price != null)
                  Container(
                    width: 1,
                    height: 16.h,
                    color: MosaedColors.fieldBorder,
                  ),
                if (price != null)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: 10.w),
                      child: MosaedSvgLabel(
                        asset: ImageAssets.money03,
                        labelWidget: MosaedPriceText(
                          amount: price,
                          style: getMediumStyle(
                            fontSize: 11.sp,
                            color: MosaedColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
