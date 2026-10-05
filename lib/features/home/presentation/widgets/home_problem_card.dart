import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';

class HomeProblemCard extends StatelessWidget {
  const HomeProblemCard({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              Color(0xFFFFF8F2),
              Color(0xFFFEF3EB),
              Color(0xFFFFE0C8),
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.mosaedWhatsYourProblem.tr(),
              style: getSemiBoldStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              readOnly: true,
              canRequestFocus: false,
              onTap: onStart,
              maxLines: 3,
              minLines: 2,
              style: getRegularStyle(
                fontSize: 11.sp,
                color: MosaedColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: LocaleKeys.mosaedTellUsProblem.tr(),
                hintStyle: getRegularStyle(
                  fontSize: 11.sp,
                  color: MosaedColors.textHint,
                ),
                filled: true,
                fillColor: MosaedColors.surfaceWhite,
                contentPadding: EdgeInsets.all(14.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: MosaedColors.fieldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: MosaedColors.brand,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            MosaedPrimaryButton(
              text: LocaleKeys.mosaedStartYourRequest.tr(),
              onPressed: onStart,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}
