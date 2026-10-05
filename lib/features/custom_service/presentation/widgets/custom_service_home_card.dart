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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: MosaedColors.primaryContainer,
            width: 1.4,
          ),
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
                      fontSize: 12.sp,
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
                    fontSize: 13.sp,
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
                color: MosaedColors.primaryContainer,
                borderRadius: BorderRadius.circular(16.r),
                elevation: 1,
                shadowColor: MosaedColors.primary.withValues(alpha: 0.25),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      'next'.tr(),
                      style: getBoldStyle(
                        fontSize: 12.sp,
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
