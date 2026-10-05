import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../../../core/widgets/mosaed_price_text.dart';
import '../../../auth/presentation/widgets/mosaed_buttons.dart';
import '../../data/completion_form_model.dart';
import '../../data/order_model.dart';
import '../widgets/active_order/active_order_shared.dart';

class ServiceOrderExtras extends StatelessWidget {
  const ServiceOrderExtras({
    super.key,
    required this.order,
    required this.completion,
    required this.customerRating,
    required this.complaintSubmitted,
    required this.complaintController,
    required this.submittingComplaint,
    required this.onSubmitRating,
    required this.onSubmitComplaint,
    required this.valueOf,
  });

  final ServiceOrder order;
  final CompletionForm? completion;
  final double customerRating;
  final bool complaintSubmitted;
  final TextEditingController complaintController;
  final bool submittingComplaint;
  final void Function(int stars) onSubmitRating;
  final VoidCallback onSubmitComplaint;
  final String Function(String value) valueOf;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (order.bookingItems.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _BookingItemsSection(order: order),
        ],
        if (!order.isPending) ...[
          SizedBox(height: 12.h),
          _UsedItemsSection(
            order: order,
            completion: completion,
            valueOf: valueOf,
          ),
        ],
        if (order.isCompleted && customerRating > 0) ...[
          SizedBox(height: 12.h),
          _RatingSection(
            order: order,
            customerRating: customerRating,
          ),
        ],
        if (order.isCompleted) ...[
          SizedBox(height: 12.h),
          _ComplaintSection(
            complaintSubmitted: complaintSubmitted,
            complaintController: complaintController,
            submittingComplaint: submittingComplaint,
            onSubmitComplaint: onSubmitComplaint,
          ),
        ],
      ],
    );
  }
}

class _BookingItemsSection extends StatelessWidget {
  const _BookingItemsSection({required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    return ActiveOrderSectionCard(
      title: 'mosaedOrderItems'.tr(),
      child: Column(
        children: order.bookingItems.map((item) {
          final lineCost = item.cost ??
              (item.unitCost != null ? item.unitCost! * item.value : null);
          final qtyStyle = getRegularStyle(
            fontSize: 11.sp,
            color: MosaedColors.textSecondary,
          );
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.attributeName,
                        style: getMediumStyle(
                          fontSize: 12.sp,
                          color: MosaedColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if (item.unitCost != null)
                        MosaedPriceText(
                          amount: item.unitCost!,
                          prefix: '${item.value} × ',
                          style: qtyStyle,
                        )
                      else
                        Text('${item.value}', style: qtyStyle),
                    ],
                  ),
                ),
                if (lineCost != null)
                  MosaedPriceText(
                    amount: lineCost,
                    style: getBoldStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.primary,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UsedItemsSection extends StatelessWidget {
  const _UsedItemsSection({
    required this.order,
    required this.completion,
    required this.valueOf,
  });

  final ServiceOrder order;
  final CompletionForm? completion;
  final String Function(String value) valueOf;

  @override
  Widget build(BuildContext context) {
    final tools = completion?.toolsUsed.isNotEmpty == true
        ? completion!.toolsUsed
        : order.toolsUsed;
    final materials = completion?.materialsUsed.isNotEmpty == true
        ? completion!.materialsUsed
        : order.materialsUsed;

    return ActiveOrderSectionCard(
      title: 'mosaedUsedItems'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'mosaedToolsUsed'.tr(),
            style: getMediumStyle(
              fontSize: 11.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          if (tools.isEmpty)
            Text('mosaedNotAvailableYet'.tr())
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  tools.map((tool) => _Chip(text: valueOf(tool))).toList(),
            ),
          SizedBox(height: 12.h),
          Text(
            'mosaedMaterialsUsed'.tr(),
            style: getMediumStyle(
              fontSize: 11.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          if (materials.isEmpty)
            Text('mosaedNotAvailableYet'.tr())
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: materials
                  .map((item) => _Chip(text: valueOf(item)))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.order,
    required this.customerRating,
  });

  final ServiceOrder order;
  final double customerRating;

  @override
  Widget build(BuildContext context) {
    return ActiveOrderSectionCard(
      title: 'mosaedRatingSection'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActiveOrderDetailRow(
            svgAsset: ImageAssets.starBadge,
            label: 'mosaedWorkerRating'.tr(),
            child: Text(
              order.workerRating > 0
                  ? '${order.workerRating} ⭐'
                  : 'mosaedNotAvailableYet'.tr(),
              style: getMediumStyle(
                fontSize: 13.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'mosaedYourRating'.tr(),
            style: getMediumStyle(
              fontSize: 11.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < customerRating.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: const Color(0xFFF59E0B),
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintSection extends StatelessWidget {
  const _ComplaintSection({
    required this.complaintSubmitted,
    required this.complaintController,
    required this.submittingComplaint,
    required this.onSubmitComplaint,
  });

  final bool complaintSubmitted;
  final TextEditingController complaintController;
  final bool submittingComplaint;
  final VoidCallback onSubmitComplaint;

  @override
  Widget build(BuildContext context) {
    return ActiveOrderSectionCard(
      title: 'mosaedComplaintSection'.tr(),
      child: complaintSubmitted
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: MosaedColors.successBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: MosaedColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: MosaedColors.success,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'mosaedComplaintReceived'.tr(),
                      style: getMediumStyle(
                        fontSize: 12.sp,
                        color: MosaedColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'mosaedComplaintHint'.tr(),
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: MosaedColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: complaintController,
                  maxLines: 4,
                  style: getRegularStyle(
                    fontSize: 13.sp,
                    color: MosaedColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'mosaedComplaintPlaceholder'.tr(),
                    hintStyle: getRegularStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.textHint,
                    ),
                    filled: true,
                    fillColor: MosaedColors.inputFill,
                    contentPadding: EdgeInsets.all(12.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: MosaedColors.primaryContainer,
                        width: 1.4,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: MosaedColors.primaryContainer,
                        width: 1.8,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: MosaedColors.primaryContainer,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                MosaedPrimaryButton(
                  text: 'mosaedSubmitComplaint'.tr(),
                  icon: Icons.send_rounded,
                  isLoading: submittingComplaint,
                  onPressed: onSubmitComplaint,
                ),
              ],
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MosaedColors.inputFill,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: getRegularStyle(fontSize: 11.sp, color: MosaedColors.textPrimary),
      ),
    );
  }
}
