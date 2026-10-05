import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/mosaed_colors.dart';
import '../constants/styles_manager.dart';

class MosaedPhotoThumb extends StatelessWidget {
  const MosaedPhotoThumb({
    super.key,
    required this.cover,
    this.photoCount = 0,
    this.size = 80,
    this.showCountFrom = 1,
  });

  final String? cover;
  final int photoCount;
  final double size;
  final int showCountFrom;

  @override
  Widget build(BuildContext context) {
    final hasCover = cover != null && cover!.trim().isNotEmpty;
    final dim = size.w;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: dim,
        height: dim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: MosaedColors.surfaceContainerLow,
              child: hasCover
                  ? Image.network(
                      cover!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.image_outlined,
                        color: MosaedColors.textHint,
                        size: 28.sp,
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      color: MosaedColors.textHint,
                      size: 28.sp,
                    ),
            ),
            if (photoCount >= showCountFrom && photoCount > 0)
              PositionedDirectional(
                start: 6.w,
                bottom: 6.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera_rounded,
                        size: 11.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '$photoCount',
                        style:
                            getBoldStyle(fontSize: 10.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
