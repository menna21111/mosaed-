import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_icon_circle.dart';

class ServiceInfoRow extends StatelessWidget {
  const ServiceInfoRow({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
    required this.value,
    this.valueColor,
  }) : assert(icon != null || svgAsset != null);

  final IconData? icon;
  final String? svgAsset;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MosaedIconCircle(
            icon: icon,
            svgAsset: svgAsset,
            size: 40,
            radius: 10,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getBoldStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.brand,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: getMediumStyle(
                    fontSize: 13.sp,
                    color: valueColor ?? MosaedColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
