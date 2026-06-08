import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../auth/presentation/widgets/mosaed_buttons.dart';
import 'request_service_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _offers = [
    ('خصم 30%', 'على خدمات السباكة'),
    ('عرض خاص', 'عزل الأسطح بأسعار مميزة'),
    ('صيانة كهربائية', 'فني معتمد خلال 24 ساعة'),
  ];

  static const _services = [
    (Icons.plumbing_rounded, 'mosaedPlumbing', Color(0xFF3B82F6)),
    (Icons.roofing_rounded, 'mosaedInsulation', Color(0xFF8B5CF6)),
    (Icons.electrical_services_rounded, 'mosaedElectric', Color(0xFFF59E0B)),
    (Icons.ac_unit_rounded, 'mosaedAc', Color(0xFF06B6D4)),
    (Icons.cleaning_services_rounded, 'mosaedCleaning', Color(0xFF10B981)),
    (Icons.format_paint_rounded, 'mosaedPainting', Color(0xFFEC4899)),
  ];

  void _openRequest(BuildContext context, {String? serviceKey}) {
    AppFunctions.navigateTo(
      context,
      RequestServiceScreen(initialServiceKey: serviceKey),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'mosaedHomeGreeting'.tr(),
                          style: getBoldStyle(
                            fontSize: 22.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'mosaedHomeSubtitle'.tr(),
                          style: getRegularStyle(
                            fontSize: 13.sp,
                            color: MosaedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: MosaedColors.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: MosaedColors.border),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverToBoxAdapter(
            child: CarouselSlider(
              options: CarouselOptions(
                height: 150.h,
                viewportFraction: 0.88,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              items: _offers.map((offer) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE07A3A), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        offer.$1,
                        style: getBoldStyle(fontSize: 22.sp, color: Colors.white),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        offer.$2,
                        style: getRegularStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'mosaedAvailableServices'.tr(),
                    style: getBoldStyle(
                      fontSize: 18.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                  Text(
                    'mosaedViewAll'.tr(),
                    style: getMediumStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final (icon, labelKey, color) = _services[index];
                return InkWell(
                  onTap: () => _openRequest(context, serviceKey: labelKey),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: MosaedColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: MosaedColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(icon, color: color, size: 24.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          labelKey.tr(),
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
              }, childCount: _services.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mosaedRequestService'.tr(),
                    style: getBoldStyle(
                      fontSize: 18.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: MosaedColors.surface,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: MosaedColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'mosaedRequestDesc'.tr(),
                          style: getRegularStyle(
                            fontSize: 13.sp,
                            color: MosaedColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        MosaedPrimaryButton(
                          text: 'mosaedBookNow'.tr(),
                          icon: Icons.add_rounded,
                          onPressed: () => _openRequest(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}