import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_meta_bits.dart';
import '../../../../core/widgets/mosaed_network_avatar.dart';

import '../../data/models/custom_service_models.dart';

class OfferProviderCard extends StatelessWidget {
  const OfferProviderCard({super.key, required this.offer});

  final CustomOffer offer;

  @override
  Widget build(BuildContext context) {
    final name = offer.providerName?.trim().isNotEmpty == true
        ? offer.providerName!
        : 'mosaedWorkerPending'.tr();
    final bio = offer.providerBio?.trim();
    final distance = offer.distanceKm;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MosaedNetworkAvatar(url: offer.providerImage, size: 52),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: getBoldStyle(
                        fontSize: 15.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    ProviderStatsRow(offer: offer),
                  ],
                ),
              ),
            ],
          ),
          if (bio != null && bio.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              bio,
              style: getRegularStyle(
                fontSize: 12.sp,
                color: MosaedColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          if (distance != null) ...[
            SizedBox(height: 10.h),
            MosaedDistanceChip(km: distance),
          ],
        ],
      ),
    );
  }
}

class ProviderStatsRow extends StatelessWidget {
  const ProviderStatsRow({super.key, required this.offer, this.compact = false});

  final CustomOffer offer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rating = offer.providerRating;
    final jobs = offer.providerJobsCount;
    final city = offer.providerCity?.trim();
    final fontSize = compact ? 11.0 : 12.0;

    return Wrap(
      spacing: 8.w,
      runSpacing: 4.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (jobs != null)
          Text(
            LocaleKeys.mosaedServicesCount.tr(args: ['$jobs']),
            style: getRegularStyle(
              fontSize: fontSize.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        if (rating != null) ...[
          Icon(Icons.star_rounded, size: 14.sp, color: MosaedColors.brand),
          Text(
            rating.toStringAsFixed(1),
            style: getMediumStyle(
              fontSize: fontSize.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
        ],
        if (city != null && city.isNotEmpty) ...[
          Icon(Icons.location_on_outlined, size: 13.sp, color: MosaedColors.textHint),
          Text(
            city,
            style: getRegularStyle(
              fontSize: fontSize.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
