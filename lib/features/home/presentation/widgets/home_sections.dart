import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/home_shimmer.dart';
import '../../../custom_service/data/models/custom_service_models.dart';
import '../../../services/data/models/existed_service.dart';
import 'home_quick_access.dart';
import 'home_recent_request_card.dart';
import 'home_services_strip.dart';

class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({
    super.key,
    required this.loading,
    required this.services,
    required this.onTap,
    this.error,
  });

  final bool loading;
  final List<ExistedService> services;
  final ValueChanged<ExistedService> onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(LocaleKeys.mosaedOurServices.tr()),
        SizedBox(height: 12.h),
        if (loading)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const HomeShimmer(),
          )
        else if (services.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              error ?? 'noCategories'.tr(),
              style: getRegularStyle(
                fontSize: 11.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          )
        else
          HomeServicesStrip(services: services, onTap: onTap),
      ],
    );
  }
}

class HomeRecentRequestsStrip extends StatelessWidget {
  const HomeRecentRequestsStrip({
    super.key,
    required this.loading,
    required this.requests,
    required this.onTap,
  });

  final bool loading;
  final List<CustomRequest> requests;
  final ValueChanged<CustomRequest> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(LocaleKeys.mosaedLatestRequests.tr()),
        SizedBox(height: 12.h),
        if (!loading && requests.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              LocaleKeys.mosaedNoRecentRequests.tr(),
              style: getRegularStyle(
                fontSize: 11.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          )
        else if (requests.isNotEmpty)
          SizedBox(
            height: 120.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: requests.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final req = requests[index];
                return HomeRecentRequestCard(
                  request: req,
                  onTap: () => onTap(req),
                );
              },
            ),
          ),
      ],
    );
  }
}

class HomeQuickAccessSection extends StatelessWidget {
  const HomeQuickAccessSection({
    super.key,
    required this.pointsBalance,
    required this.addressLabel,
    required this.onAddressesTap,
    required this.onPointsTap,
  });

  final String pointsBalance;
  final String addressLabel;
  final VoidCallback onAddressesTap;
  final VoidCallback onPointsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(LocaleKeys.mosaedQuickAccess.tr()),
        SizedBox(height: 12.h),
        HomeQuickAccessRow(
          pointsBalance: pointsBalance,
          addressLabel: addressLabel,
          onAddressesTap: onAddressesTap,
          onPointsTap: onPointsTap,
        ),
      ],
    );
  }
}
