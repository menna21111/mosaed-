import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../services/data/models/address_models.dart';
import '../../data/models/custom_service_models.dart';
import 'custom_request_chrome.dart';

class StepReview extends StatelessWidget {
  const StepReview({
    super.key,
    required this.title,
    required this.description,
    required this.specialization,
    required this.images,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.onEditStep,
  });

  final String title;
  final String description;
  final Specialization? specialization;
  final List<File> images;
  final CustomerAddress? address;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final ValueChanged<int> onEditStep;

  String get _locationLabel {
    if (address == null) return '—';
    final city = address!.cityName.trim();
    final district = address!.district.trim();
    if (city.isNotEmpty && district.isNotEmpty) return '$district، $city';
    return address!.fullAddress;
  }

  String get _appointmentLabel {
    if (scheduledDate == null || scheduledTime == null) return '—';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      scheduledDate!.year,
      scheduledDate!.month,
      scheduledDate!.day,
    );
    final diff = day.difference(today).inDays;
    final dayText = diff == 0
        ? LocaleKeys.mosaedToday.tr()
        : diff == 1
            ? LocaleKeys.mosaedTomorrow.tr()
            : DateFormat('EEEE').format(scheduledDate!);

    final hour = scheduledTime!.hourOfPeriod == 0
        ? 12
        : scheduledTime!.hourOfPeriod;
    final period = scheduledTime!.period == DayPeriod.am ? 'ص' : 'م';
    final mm = scheduledTime!.minute.toString().padLeft(2, '0');
    return '$dayText، $hour:$mm $period';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      children: [
        CustomRequestStepHeader(
          title: LocaleKeys.mosaedReviewRequest.tr(),
          subtitle: LocaleKeys.mosaedReviewRequestSubtitle.tr(),
        ),
        SizedBox(height: 20.h),
        _ReviewCard(
          label: LocaleKeys.mosaedProblemLabel.tr(),
          onEdit: () => onEditStep(0),
          child: Text(
            title,
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
        _ReviewCard(
          label: LocaleKeys.mosaedProblemDescription.tr(),
          onEdit: () => onEditStep(0),
          child: Text(
            description,
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textPrimary,
              height: 1.45,
            ),
          ),
        ),
        _ReviewCard(
          label: LocaleKeys.mosaedServiceType.tr(),
          onEdit: () => onEditStep(0),
          child: Text(
            specialization?.name ?? '—',
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
        ),
        _ReviewCard(
          label: LocaleKeys.mosaedProblemPhotos.tr(),
          onEdit: () => onEditStep(1),
          child: images.isEmpty
              ? Text(
                  '—',
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textSecondary,
                  ),
                )
              : SizedBox(
                  height: 56.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        images[i],
                        width: 56.w,
                        height: 56.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
        ),
        _ReviewCard(
          label: LocaleKeys.mosaedServiceLocation.tr(),
          onEdit: () => onEditStep(2),
          child: Text(
            _locationLabel,
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
        ),
        _ReviewCard(
          label: LocaleKeys.mosaedAppointment.tr(),
          onEdit: () => onEditStep(3),
          child: Text(
            _appointmentLabel,
            style: getRegularStyle(
              fontSize: 13.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.label,
    required this.child,
    required this.onEdit,
  });

  final String label;
  final Widget child;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MosaedColors.fieldBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: getBoldStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  child,
                ],
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onEdit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 14.sp,
                    color: MosaedColors.brand,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    LocaleKeys.mosaedEdit.tr(),
                    style: getBoldStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
