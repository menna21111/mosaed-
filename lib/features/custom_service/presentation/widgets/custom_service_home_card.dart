import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class CustomServiceHomeCard extends StatelessWidget {
  const CustomServiceHomeCard({super.key, required this.onTap});

  final VoidCallback onTap;

  static const _brandShadow = Color(0x14BD5E19);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: _brandShadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB85A15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    Icons.manage_accounts_rounded,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'mosaedCustomServiceHomeDesc'.tr(),
                    style: getRegularStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: MosaedColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'mosaedCustomProblemHint'.tr(),
                  style: getRegularStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: const Color(0xFFE5E2E1)),
            SizedBox(height: 12.h),
            Center(
              child: Material(
                color: MosaedColors.primary,
                borderRadius: BorderRadius.circular(8.r),
                elevation: 1,
                shadowColor: MosaedColors.primary.withValues(alpha: 0.25),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      'next'.tr(),
                      style: getBoldStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
