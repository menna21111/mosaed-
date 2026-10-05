import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_meta_bits.dart';
import '../../../../core/widgets/mosaed_photo_thumb.dart';
import '../../../../core/widgets/mosaed_price_text.dart';
import '../../../../core/widgets/mosaed_ribbon_card.dart';
import '../../../../core/widgets/mosaed_svg_chip.dart';
import '../../../orders/data/order_model.dart';
import '../../../orders/presentation/models/active_order_view_data.dart';

class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({
    super.key,
    required this.message,
    required this.onRefresh,
  });

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MosaedColors.brand,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          ImageAssets.ordersEmpty,
                          width: 220.w,
                          height: 200.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: getBoldStyle(
                            fontSize: 17.sp,
                            color: MosaedColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OrdersLoadError extends StatelessWidget {
  const OrdersLoadError({
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
            Icon(
              Icons.cloud_off_rounded,
              size: 40.sp,
              color: MosaedColors.textHint,
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 12.sp,
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

class ServiceBookingOrderCard extends StatelessWidget {
  const ServiceBookingOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final ServiceOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final schedule = order.scheduledSlot.startsWith('mosaed')
        ? order.scheduledSlot.tr()
        : order.scheduledSlot;
    final relative = ActiveOrderViewData.relativeTimeAgo(order.createdAt);
    final notes = order.notes.startsWith('mosaed') ? '' : order.notes.trim();
    final price = order.agreedAmount > 0 ? order.agreedAmount : null;

    return MosaedRibbonCard(
      statusLabel: order.statusKey.tr(),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.serviceTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getBoldStyle(
                    fontSize: 15.sp,
                    color: MosaedColors.textPrimary,
                  ),
                ),
                if (relative.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  MosaedClockLabel(label: relative),
                ],
                if (notes.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (schedule.isNotEmpty)
                      MosaedSvgChip(
                        svgAsset: ImageAssets.calendar03,
                        label: schedule,
                        tintSvg: true,
                      ),
                    if (price != null)
                      MosaedSvgChip(
                        svgAsset: ImageAssets.money03,
                        labelWidget: MosaedPriceText(
                          amount: price,
                          style: getMediumStyle(
                            fontSize: 11.sp,
                            color: MosaedColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        tintSvg: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          MosaedPhotoThumb(cover: order.serviceImage),
        ],
      ),
    );
  }
}
