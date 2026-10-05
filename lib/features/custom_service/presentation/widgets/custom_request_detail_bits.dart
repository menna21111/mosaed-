import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../data/models/custom_service_models.dart';

class EmptyOffersCard extends StatelessWidget {
  const EmptyOffersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.local_offer_outlined, size: 32.sp, color: MosaedColors.textHint),
          SizedBox(height: 8.h),
          Text(
            'mosaedNoOffersYet'.tr(),
            style: getMediumStyle(
              fontSize: 14.sp,
              color: MosaedColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'mosaedNoOffersYetHint'.tr(),
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: 12.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class AcceptedProviderBanner extends StatelessWidget {
  const AcceptedProviderBanner({super.key, required this.request});

  final CustomRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.success),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: MosaedColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: MosaedColors.success,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.providerName?.trim().isNotEmpty == true
                      ? request.providerName!
                      : 'mosaedWorkerPending'.tr(),
                  style: getBoldStyle(
                    fontSize: 14.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'mosaedOfferAcceptedBadge'.tr(),
                  style: getMediumStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRequestActionsBar extends StatelessWidget {
  const CustomRequestActionsBar({
    super.key,
    required this.onEdit,
    required this.onCancel,
    this.cancelling = false,
  });

  final VoidCallback onEdit;
  final VoidCallback? onCancel;
  final bool cancelling;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: MosaedColors.surfaceWhite,
        border: Border(top: BorderSide(color: MosaedColors.fieldBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: MosaedPrimaryButton(
                text: LocaleKeys.mosaedEditOrder.tr(),
                onPressed: onEdit,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: MosaedOutlineButton(
                text: LocaleKeys.mosaedCancelCustomRequest.tr(),
                onPressed: cancelling ? null : onCancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OffersSectionHeader extends StatelessWidget {
  const OffersSectionHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.mosaedPriceOffersTitle.tr(),
          style: getBoldStyle(fontSize: 16.sp, color: MosaedColors.textPrimary),
        ),
        SizedBox(height: 4.h),
        Text(
          count > 0
              ? LocaleKeys.mosaedOffersReceivedHint.tr(args: ['$count'])
              : 'mosaedNoOffersYetHint'.tr(),
          style: getRegularStyle(
            fontSize: 12.sp,
            color: MosaedColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class RequestLoadError extends StatelessWidget {
  const RequestLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48.sp, color: MosaedColors.textHint),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 14.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('mosaedRetry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
