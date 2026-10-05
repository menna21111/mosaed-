import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import 'custom_request_chrome.dart';

class StepPhotos extends StatelessWidget {
  const StepPhotos({
    super.key,
    required this.images,
    required this.maxPhotos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> images;
  final int maxPhotos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  int get _remaining => maxPhotos - images.length;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        CustomRequestStepHeader(
          title: LocaleKeys.mosaedAddProblemPhotosTitle.tr(),
          subtitle: LocaleKeys.mosaedAddProblemPhotosSubtitle.tr(),
        ),
        SizedBox(height: 20.h),
        if (images.isEmpty) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              LocaleKeys.mosaedProblemPhotos.tr(),
              style: getMediumStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          _EmptyUpload(onAdd: onAdd),
          SizedBox(height: 16.h),
          const _PhotoTipsCard(),
        ] else ...[
          _PhotosGrid(
            images: images,
            canAdd: _remaining > 0,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
          SizedBox(height: 14.h),
          _PhotosLimitBanner(
            remaining: _remaining,
            maxPhotos: maxPhotos,
          ),
        ],
      ],
    );
  }
}

class _PhotosLimitBanner extends StatelessWidget {
  const _PhotosLimitBanner({
    required this.remaining,
    required this.maxPhotos,
  });

  final int remaining;
  final int maxPhotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: MosaedColors.brandTransparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              color: MosaedColors.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'i',
              style: getBoldStyle(fontSize: 11.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              remaining > 0
                  ? LocaleKeys.mosaedPhotosRemaining.tr(args: ['$maxPhotos'])
                  : LocaleKeys.mosaedPhotosMaxReached.tr(args: ['$maxPhotos']),
              style: getMediumStyle(
                fontSize: 12.sp,
                color: MosaedColors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUpload extends StatelessWidget {
  const _EmptyUpload({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MosaedColors.fieldBorder),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              ImageAssets.addPhotosButton,
              width: 36.w,
              height: 36.w,
              colorFilter: const ColorFilter.mode(
                MosaedColors.brand,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.mosaedAddPhotosDashed.tr(),
              style: getBoldStyle(
                fontSize: 14.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              LocaleKeys.mosaedSupportedFormats.tr(),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 11.sp,
                color: MosaedColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({
    required this.images,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> images;
  final bool canAdd;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final count = images.length + (canAdd ? 1 : 0);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
      ),
      itemBuilder: (context, index) {
        if (canAdd && index == images.length) {
          return GestureDetector(
            onTap: onAdd,
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: MosaedColors.brand.withValues(alpha: 0.7),
                radius: 12.r,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageAssets.addPhotosButton,
                    width: 26.w,
                    height: 26.w,
                    colorFilter: const ColorFilter.mode(
                      MosaedColors.brand,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    LocaleKeys.mosaedAddPhotoShort.tr(),
                    style: getMediumStyle(
                      fontSize: 11.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(images[index], fit: BoxFit.cover),
            ),
            PositionedDirectional(
              top: 6.h,
              start: 6.w,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PhotoTipsCard extends StatelessWidget {
  const _PhotoTipsCard();

  @override
  Widget build(BuildContext context) {
    final tips = [
      LocaleKeys.mosaedPhotoTip1.tr(),
      LocaleKeys.mosaedPhotoTip2.tr(),
      LocaleKeys.mosaedPhotoTip3.tr(),
      LocaleKeys.mosaedPhotoTip4.tr(),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.mosaedPhotoTipsTitle.tr(),
            style: getBoldStyle(
              fontSize: 13.sp,
              color: MosaedColors.brand,
            ),
          ),
          SizedBox(height: 10.h),
          ...tips.map(
            (t) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    ImageAssets.checkmarkCircle03,
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      t,
                      style: getRegularStyle(
                        fontSize: 12.sp,
                        color: MosaedColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

Future<ImageSource?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: MosaedColors.fieldBorder,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  LocaleKeys.mosaedAddPhoto.tr(),
                  style: getBoldStyle(
                    fontSize: 16.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                _PhotoSourceOption(
                  svgAsset: ImageAssets.cameraIcon,
                  label: LocaleKeys.mosaedTakePhoto.tr(),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                SizedBox(height: 10.h),
                _PhotoSourceOption(
                  svgAsset: ImageAssets.image02,
                  label: LocaleKeys.mosaedPickFromGallery.tr(),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PhotoSourceOption extends StatelessWidget {
  const _PhotoSourceOption({
    required this.svgAsset,
    required this.label,
    required this.onTap,
  });

  final String svgAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: MosaedColors.brand.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 22.w,
              height: 22.w,
              colorFilter: const ColorFilter.mode(
                MosaedColors.brand,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: getMediumStyle(
                  fontSize: 14.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

