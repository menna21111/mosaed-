import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class AddressesEmptyState extends StatelessWidget {
  const AddressesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              ImageAssets.noPlaces,
              width: 220.w,
              height: 180.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            Text(
              LocaleKeys.mosaedNoAddressYet.tr(),
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: 16.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
