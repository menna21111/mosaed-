import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.onEdit,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;

    return Material(
      color: MosaedColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: MosaedColors.fieldBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: MosaedColors.otpFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: MosaedColors.fieldBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasPhoto
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person_rounded,
                          color: MosaedColors.brand,
                          size: 24.sp,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: MosaedColors.brand,
                        size: 24.sp,
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: getBoldStyle(
                        fontSize: 15.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      LocaleKeys.mosaedEditProfile.tr(),
                      style: getRegularStyle(
                        fontSize: 12.sp,
                        color: MosaedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22.sp,
                color: MosaedColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
