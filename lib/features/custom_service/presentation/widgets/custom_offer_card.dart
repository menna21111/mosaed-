import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_meta_bits.dart';
import '../../../../core/widgets/mosaed_network_avatar.dart';
import '../../../../core/widgets/mosaed_price_text.dart';
import '../../data/models/custom_service_models.dart';
import 'offer_provider_card.dart';

class CustomOfferCard extends StatelessWidget {
  const CustomOfferCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final CustomOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = offer.providerName?.trim().isNotEmpty == true
        ? offer.providerName!
        : 'mosaedWorkerPending'.tr();
    final bio = offer.providerBio?.trim();
    final distance = offer.distanceKm;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: MosaedColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: offer.isAccepted
                ? MosaedColors.success
                : MosaedColors.fieldBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MosaedNetworkAvatar(url: offer.providerImage),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getBoldStyle(
                          fontSize: 14.sp,
                          color: MosaedColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ProviderStatsRow(offer: offer, compact: true),
                    ],
                  ),
                ),
              ],
            ),
            if (bio != null && bio.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getRegularStyle(
                  fontSize: 12.sp,
                  color: MosaedColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            if (distance != null) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: MosaedDistanceChip(km: distance),
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(height: 1, color: MosaedColors.fieldBorder),
            ),
            OfferPriceFooter(price: offer.price),
          ],
        ),
      ),
    );
  }
}

class OfferPriceFooter extends StatelessWidget {
  const OfferPriceFooter({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            LocaleKeys.mosaedTheOffer.tr(),
            style: getRegularStyle(
              fontSize: 11.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ImageAssets.tag02,
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 6.w),
              MosaedPriceText(
                amount: price,
                style: getBoldStyle(
                  fontSize: 16.sp,
                  color: MosaedColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
