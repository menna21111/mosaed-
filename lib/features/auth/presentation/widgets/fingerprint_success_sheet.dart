import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

Future<void> showFingerprintSuccessSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => const FingerprintSuccessSheet(),
  );
}

class FingerprintSuccessSheet extends StatefulWidget {
  const FingerprintSuccessSheet({super.key});

  @override
  State<FingerprintSuccessSheet> createState() =>
      _FingerprintSuccessSheetState();
}

class _FingerprintSuccessSheetState extends State<FingerprintSuccessSheet> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: MosaedColors.fieldBorder,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 28.h),
              Image.asset(
                'assets/images/fingerprintscuess.png',
                width: 140.w,
                height: 140.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              Text(
                'mosaedFingerprintRegistered'.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
