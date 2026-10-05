import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: MosaedColors.brandTransparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: SvgPicture.asset(
              asset,
              width: 18.w,
              height: 18.w,
            ),
          ),
          title: Text(
            label,
            style: getMediumStyle(
              fontSize: 14.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: MosaedColors.textHint,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 16.w,
            endIndent: 16.w,
            color: MosaedColors.fieldBorder,
          ),
      ],
    );
  }
}
