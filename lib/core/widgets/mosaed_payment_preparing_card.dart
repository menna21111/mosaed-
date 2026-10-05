import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/mosaed_colors.dart';
import '../constants/styles_manager.dart';

class MosaedPaymentPreparingCard extends StatelessWidget {
  const MosaedPaymentPreparingCard({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Column(
        children: [
          Text(
            'mosaedPaymentPreparingTitle'.tr(),
            style: getBoldStyle(fontSize: 13.sp, color: MosaedColors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            'mosaedPaymentPreparingHint'.tr(),
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: 12.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('mosaedRetry'.tr()),
          ),
        ],
      ),
    );
  }
}
