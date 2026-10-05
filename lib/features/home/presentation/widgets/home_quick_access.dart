import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';

class HomeQuickAccessRow extends StatelessWidget {
  const HomeQuickAccessRow({
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _QuickCard(
              title: LocaleKeys.mosaedMyAddresses.tr(),
              subtitle: addressLabel,
              iconAsset: ImageAssets.maps,
              onTap: onAddressesTap,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _QuickCard(
              title: LocaleKeys.mosaedLoyaltyPoints.tr(),
              iconAsset: ImageAssets.starBadge,
              onTap: onPointsTap,
              subtitleWidget: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: pointsBalance,
                      style: getBoldStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.brand,
                      ),
                    ),
                    TextSpan(
                      text: ' ${LocaleKeys.mosaedPointsCount.tr(args: ['']).trim()}',
                      style: getBoldStyle(
                        fontSize: 13.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.iconAsset,
    required this.onTap,
    this.subtitle,
    this.subtitleWidget,
  });

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: MosaedColors.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: MosaedColors.brandTransparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                iconAsset,
                width: 20.w,
                height: 20.w,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      fontSize: 11.sp,
                      color: MosaedColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  subtitleWidget ??
                      Text(
                        subtitle ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getSemiBoldStyle(
                          fontSize: 13.sp,
                          color: MosaedColors.textPrimary,
                        ),
                      ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: MosaedColors.textHint,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: getBoldStyle(
            fontSize: 13.sp,
            color: MosaedColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
