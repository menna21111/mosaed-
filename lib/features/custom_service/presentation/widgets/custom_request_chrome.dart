import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';

class CustomRequestProgressBar extends StatelessWidget {
  const CustomRequestProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final active = i <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 4.h,
              decoration: BoxDecoration(
                color: active ? MosaedColors.brand : MosaedColors.fieldBorder,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CustomRequestBottomBar extends StatelessWidget {
  const CustomRequestBottomBar({
    super.key,
    required this.primaryText,
    required this.onPrimary,
    this.showPrevious = false,
    this.onPrevious,
    this.isLoading = false,
  });

  final String primaryText;
  final VoidCallback? onPrimary;
  final bool showPrevious;
  final VoidCallback? onPrevious;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        border: Border(top: BorderSide(color: MosaedColors.fieldBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showPrevious) ...[
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MosaedColors.brand),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      foregroundColor: MosaedColors.brand,
                    ),
                    child: Text(
                      LocaleKeys.mosaedPrevious.tr(),
                      style: getBoldStyle(
                        fontSize: 14.sp,
                        color: MosaedColors.brand,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              flex: showPrevious ? 1 : 1,
              child: MosaedPrimaryButton(
                text: primaryText,
                isLoading: isLoading,
                enabled: onPrimary != null,
                onPressed: onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRequestStepHeader extends StatelessWidget {
  const CustomRequestStepHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: getBoldStyle(
            fontSize: 24.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: getMediumStyle(
              fontSize: 13.sp,
              color: MosaedColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}
