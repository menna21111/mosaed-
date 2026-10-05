import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class MoreCardTile extends StatelessWidget {
  const MoreCardTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leadingIcon,
    this.leadingAsset,
    this.circleIcon = false,
    this.showBorder = true,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? leadingAsset;
  final bool circleIcon;
  final bool showBorder;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MosaedColors.surfaceWhite,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: showBorder
                ? Border.all(color: MosaedColors.fieldBorder)
                : null,
          ),
          child: Row(
            children: [
              if (leadingAsset != null || leadingIcon != null) ...[
                if (circleIcon)
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: MosaedColors.otpFill,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: _leadingGraphic(size: 20),
                  )
                else
                  _leadingGraphic(size: 22),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getMediumStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: getRegularStyle(
                          fontSize: 12.sp,
                          color: MosaedColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 20.sp,
                    color: MosaedColors.textHint,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leadingGraphic({required double size}) {
    if (leadingAsset != null) {
      if (leadingAsset!.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          leadingAsset!,
          width: size.w,
          height: size.w,
        );
      }
      return Image.asset(
        leadingAsset!,
        width: size.w,
        height: size.w,
      );
    }
    return Icon(
      leadingIcon,
      color: MosaedColors.brand,
      size: size.sp,
    );
  }
}

class MoreSettingsSwitchTile extends StatelessWidget {
  const MoreSettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getMediumStyle(
                      fontSize: 14.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: getRegularStyle(
                        fontSize: 12.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: MosaedColors.brand,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
