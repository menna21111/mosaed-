import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/service_thumbnail.dart';
import '../../../services/data/models/existed_service.dart';

class HomeServicesStrip extends StatelessWidget {
  const HomeServicesStrip({
    super.key,
    required this.services,
    required this.onTap,
  });

  final List<ExistedService> services;
  final ValueChanged<ExistedService> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 123.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: services.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final service = services[index];
          return _ServiceChip(
            service: service,
            onTap: () => onTap(service),
          );
        },
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.service, required this.onTap});

  final ExistedService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 93.w,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MosaedColors.fieldBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: ServiceThumbnail(
                service: service,
                size: 64.w,
                borderRadius: BorderRadius.zero,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              service.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: getMediumStyle(
                fontSize: 11.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
