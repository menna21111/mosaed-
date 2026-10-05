import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../data/models/existed_service.dart';

class ServiceWorkGallery extends StatelessWidget {
  const ServiceWorkGallery({
    super.key,
    required this.serviceTitle,
    required this.works,
  });

  final String serviceTitle;
  final List<ServicePreviousWork> works;

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Center(
          child: Text(
            'mosaedNoPreviousWorks'.tr(),
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.mosaedWorkGalleryIntro.tr(args: [serviceTitle]),
          style: getRegularStyle(
            fontSize: 13.sp,
            color: MosaedColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        ...works.map((work) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'mosaedWorkPhotos'.tr(),
                    style: getBoldStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _GalleryPhoto(
                          url: work.beforeImage,
                          label: 'mosaedBefore'.tr(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _GalleryPhoto(
                          url: work.afterImage,
                          label: 'mosaedAfter'.tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _GalleryPhoto extends StatelessWidget {
  const _GalleryPhoto({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          PositionedDirectional(
            top: 8.h,
            end: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                label,
                style: getMediumStyle(
                  fontSize: 11.sp,
                  color: MosaedColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: MosaedColors.inputFill,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: MosaedColors.textHint,
        size: 28.sp,
      ),
    );
  }
}
