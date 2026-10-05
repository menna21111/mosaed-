import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import 'custom_request_chrome.dart';

class StepSchedule extends StatelessWidget {
  const StepSchedule({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;

  static List<DateTime> get upcomingDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(14, (i) => today.add(Duration(days: i)));
  }

  static const timeSlots = <TimeOfDay>[
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
  ];

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return LocaleKeys.mosaedToday.tr();
    if (diff == 1) return LocaleKeys.mosaedTomorrow.tr();
    return DateFormat('EEEE').format(date);
  }

  String _dateLabel(DateTime date) => DateFormat('d MMMM').format(date);

  String _timeLabel(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'ص' : 'م';
    final mm = t.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$mm $period';
  }

  bool _sameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _sameTime(TimeOfDay? a, TimeOfDay b) {
    if (a == null) return false;
    return a.hour == b.hour && a.minute == b.minute;
  }

  @override
  Widget build(BuildContext context) {
    final days = upcomingDays;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        CustomRequestStepHeader(
          title: LocaleKeys.mosaedWhenSuitsYou.tr(),
          subtitle: LocaleKeys.mosaedScheduleStepSubtitle.tr(),
        ),
        SizedBox(height: 20.h),
        Text(
          LocaleKeys.mosaedChooseDay.tr(),
          style: getBoldStyle(
            fontSize: 14.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final day = days[index];
              final selected = _sameDay(selectedDate, day);
              return GestureDetector(
                onTap: () => onDateSelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 86.w,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? MosaedColors.brandTransparent
                        : MosaedColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected
                          ? MosaedColors.brand
                          : MosaedColors.fieldBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dayLabel(day),
                        style: getBoldStyle(
                          fontSize: 12.sp,
                          color: selected
                              ? MosaedColors.brand
                              : MosaedColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _dateLabel(day),
                        style: getRegularStyle(
                          fontSize: 11.sp,
                          color: selected
                              ? MosaedColors.brand
                              : MosaedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          LocaleKeys.mosaedChooseSuitableTime.tr(),
          style: getBoldStyle(
            fontSize: 14.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeSlots.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 2.4,
          ),
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            final selected = _sameTime(selectedTime, slot);
            return GestureDetector(
              onTap: () => onTimeSelected(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? MosaedColors.brandTransparent
                      : MosaedColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selected
                        ? MosaedColors.brand
                        : MosaedColors.fieldBorder,
                  ),
                ),
                child: Text(
                  _timeLabel(slot),
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: selected
                        ? MosaedColors.brand
                        : MosaedColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
