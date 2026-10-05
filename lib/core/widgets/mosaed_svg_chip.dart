import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/mosaed_colors.dart';
import '../constants/styles_manager.dart';

class MosaedSvgChip extends StatelessWidget {
  const MosaedSvgChip({
    super.key,
    required this.svgAsset,
    this.label,
    this.labelWidget,
    this.tintSvg = false,
    this.labelColor,
    this.maxLabelWidth = 120,
  }) : assert(label != null || labelWidget != null);

  final String svgAsset;
  final String? label;
  final Widget? labelWidget;
  final bool tintSvg;
  final Color? labelColor;
  final double maxLabelWidth;

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? MosaedColors.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MosaedColors.brandTransparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 13.w,
            height: 13.w,
            colorFilter: tintSvg
                ? const ColorFilter.mode(MosaedColors.brand, BlendMode.srcIn)
                : null,
          ),
          SizedBox(width: 5.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxLabelWidth.w),
            child: labelWidget ??
                Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getMediumStyle(fontSize: 11.sp, color: color),
                ),
          ),
        ],
      ),
    );
  }
}
