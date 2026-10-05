import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/locale_keys.dart';
import '../constants/mosaed_colors.dart';
import '../constants/styles_manager.dart';

class MosaedClockLabel extends StatelessWidget {
  const MosaedClockLabel({
    super.key,
    required this.label,
    this.iconSize = 13,
    this.fontSize = 11,
  });

  final String label;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: iconSize.sp,
          color: MosaedColors.textHint,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: getRegularStyle(
            fontSize: fontSize.sp,
            color: MosaedColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class MosaedDistanceChip extends StatelessWidget {
  const MosaedDistanceChip({super.key, required this.km});

  final double km;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MosaedColors.brandTransparent,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, size: 13.sp, color: MosaedColors.brand),
          SizedBox(width: 4.w),
          Text(
            LocaleKeys.mosaedDistanceAway.tr(args: [km.toStringAsFixed(1)]),
            style: getMediumStyle(fontSize: 11.sp, color: MosaedColors.brand),
          ),
        ],
      ),
    );
  }
}

class MosaedOffersCountRow extends StatelessWidget {
  const MosaedOffersCountRow({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.groups_rounded, size: 18.sp, color: MosaedColors.brand),
        SizedBox(width: 6.w),
        Text(
          LocaleKeys.mosaedPriceOffersCount.tr(args: ['$count']),
          style: getBoldStyle(fontSize: 13.sp, color: MosaedColors.brand),
        ),
      ],
    );
  }
}

class MosaedSvgLabel extends StatelessWidget {
  const MosaedSvgLabel({
    super.key,
    required this.asset,
    this.label,
    this.labelWidget,
    this.iconSize = 16,
    this.fontSize = 12,
  }) : assert(label != null || labelWidget != null);

  final String asset;
  final String? label;
  final Widget? labelWidget;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(asset, width: iconSize.w, height: iconSize.w),
        SizedBox(width: 6.w),
        Expanded(
          child: labelWidget ??
              Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getMediumStyle(
                  fontSize: fontSize.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
        ),
      ],
    );
  }
}
