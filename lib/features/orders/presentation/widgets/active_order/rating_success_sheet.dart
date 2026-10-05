import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/functions.dart';
import '../../../../../core/constants/locale_keys.dart';
import '../../../../../core/constants/mosaed_colors.dart';
import '../../../../../core/constants/styles_manager.dart';
import '../../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../../../home/presentation/main_shell.dart';

class RatingSuccessSheet extends StatelessWidget {
  const RatingSuccessSheet({super.key, required this.technicianName});

  final String technicianName;

  static Future<void> show(
    BuildContext context, {
    required String technicianName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => RatingSuccessSheet(technicianName: technicianName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: MosaedColors.brand.withValues(alpha: 0.25),
                  size: 72.sp,
                ),
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: const BoxDecoration(
                    color: MosaedColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              LocaleKeys.mosaedRatingSentTitle.tr(),
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: 18.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              LocaleKeys.mosaedRatingSentBody.tr(args: [technicianName]),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.h),
            MosaedPrimaryButton(
              text: LocaleKeys.mosaedBackToHome.tr(),
              onPressed: () {
                Navigator.of(context).pop();
                AppFunctions.navigateToAndFinish(
                  context,
                  const MainShell(initialIndex: 0),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
