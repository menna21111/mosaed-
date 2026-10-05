import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class ChatTodayChip extends StatelessWidget {
  const ChatTodayChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: MosaedColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            LocaleKeys.mosaedToday.tr(),
            style: getMediumStyle(
              fontSize: 11.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
