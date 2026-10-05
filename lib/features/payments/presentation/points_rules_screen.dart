import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../services/presentation/widgets/address_chrome.dart';

class PointsRulesScreen extends StatelessWidget {
  const PointsRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.surfaceWhite,
      appBar: AddressAppBar(title: LocaleKeys.mosaedLoyaltyRulesTitle.tr()),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              ImageAssets.pointsGifts,
              width: double.infinity,
              height: 140.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            LocaleKeys.mosaedHowCollectPoints.tr(),
            style: getBoldStyle(
              fontSize: 15.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          _RulesCard(
            items: [
              (
                ImageAssets.starPng,
                LocaleKeys.mosaedRuleOrderMoreTitle.tr(),
                LocaleKeys.mosaedRuleOrderMoreBody.tr(),
              ),
              (
                ImageAssets.message02,
                LocaleKeys.mosaedRuleShareOpinionTitle.tr(),
                LocaleKeys.mosaedRuleShareOpinionBody.tr(),
              ),
              (
                ImageAssets.gift,
                LocaleKeys.mosaedRuleOffersTitle.tr(),
                LocaleKeys.mosaedRuleOffersBody.tr(),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            LocaleKeys.mosaedHowUsePoints.tr(),
            style: getBoldStyle(
              fontSize: 15.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          _RulesCard(
            items: [
              (
                ImageAssets.percent,
                LocaleKeys.mosaedRuleDiscountsTitle.tr(),
                LocaleKeys.mosaedRuleDiscountsBody.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.items});

  final List<(String, String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: MosaedColors.otpFill,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: _assetIcon(items[i].$1),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].$2,
                          style: getBoldStyle(
                            fontSize: 13.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          items[i].$3,
                          style: getRegularStyle(
                            fontSize: 12.sp,
                            color: MosaedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1)
              Divider(
                height: 1,
                indent: 16.w,
                endIndent: 16.w,
                color: MosaedColors.fieldBorder,
              ),
          ],
        ],
      ),
    );
  }

  Widget _assetIcon(String asset) {
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(asset, width: 20.w, height: 20.w);
    }
    return Image.asset(asset, width: 20.w, height: 20.w);
  }
}
