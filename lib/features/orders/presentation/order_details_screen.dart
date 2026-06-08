import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../orders/data/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'mosaedOrderDetails'.tr(args: [order.id]),
          style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(order: order),
            SizedBox(height: 16.h),
            _Section(
              title: 'mosaedWorkerInfo'.tr(),
              child: _WorkerCard(order: order),
            ),
            SizedBox(height: 16.h),
            _Section(
              title: 'mosaedPaymentInfo'.tr(),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'mosaedAgreedAmount'.tr(),
                    value: '${order.agreedAmount.toStringAsFixed(0)} ${'mosaedCurrency'.tr()}',
                  ),
                  _InfoRow(
                    label: 'mosaedPaymentStatus'.tr(),
                    value: order.paymentReceived
                        ? 'mosaedPaymentReceived'.tr()
                        : 'mosaedPaymentPending'.tr(),
                    valueColor:
                        order.paymentReceived ? MosaedColors.success : MosaedColors.danger,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _Section(
              title: 'mosaedTimeline'.tr(),
              child: Column(
                children: [
                  _InfoRow(label: 'mosaedScheduledTime'.tr(), value: order.scheduledSlot.tr()),
                  _InfoRow(label: 'mosaedArrivalTime'.tr(), value: order.arrivedAt.tr()),
                  _InfoRow(label: 'mosaedFinishTime'.tr(), value: order.finishedAt.tr()),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _Section(
              title: 'mosaedUsedItems'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mosaedToolsUsed'.tr(),
                    style: getMediumStyle(fontSize: 13.sp, color: MosaedColors.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  if (order.toolsUsed.isEmpty)
                    Text('mosaedNotAvailableYet'.tr())
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: order.toolsUsed
                          .map((tool) => _Chip(text: tool.tr()))
                          .toList(),
                    ),
                  SizedBox(height: 14.h),
                  Text(
                    'mosaedMaterialsUsed'.tr(),
                    style: getMediumStyle(fontSize: 13.sp, color: MosaedColors.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  if (order.materialsUsed.isEmpty)
                    Text('mosaedNotAvailableYet'.tr())
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: order.materialsUsed
                          .map((item) => _Chip(text: item.tr()))
                          .toList(),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _Section(
              title: 'mosaedRatingSection'.tr(),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'mosaedWorkerRating'.tr(),
                    value: order.workerRating > 0
                        ? '${order.workerRating} ⭐'
                        : 'mosaedNotAvailableYet'.tr(),
                  ),
                  _InfoRow(
                    label: 'mosaedYourRating'.tr(),
                    value: order.customerRating > 0
                        ? '${order.customerRating} ⭐'
                        : 'mosaedRateAfterFinish'.tr(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _Section(
              title: 'mosaedOrderNotes'.tr(),
              child: Text(
                order.notes.tr(),
                style: getRegularStyle(fontSize: 14.sp, color: MosaedColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  order.serviceKey.tr(),
                  style: getBoldStyle(fontSize: 20.sp, color: MosaedColors.textPrimary),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  order.statusKey.tr(),
                  style: getMediumStyle(fontSize: 11.sp, color: order.statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16.sp, color: MosaedColors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  order.locationText,
                  style: getRegularStyle(fontSize: 13.sp, color: MosaedColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    if (order.workerName == 'mosaedWorkerPending') {
      return Text(
        'mosaedWorkerAssigning'.tr(),
        style: getRegularStyle(fontSize: 14.sp, color: MosaedColors.textSecondary),
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: MosaedColors.shieldBg,
          child: Icon(Icons.engineering_rounded, color: MosaedColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.workerName,
                style: getBoldStyle(fontSize: 16.sp, color: MosaedColors.textPrimary),
              ),
              SizedBox(height: 4.h),
              Text(
                '${order.workerRating} ⭐ • ${order.workerJobsCount} ${'mosaedCompletedJobs'.tr()}',
                style: getRegularStyle(fontSize: 12.sp, color: MosaedColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MosaedColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: MosaedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getBoldStyle(fontSize: 15.sp, color: MosaedColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: getRegularStyle(fontSize: 13.sp, color: MosaedColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: getMediumStyle(
              fontSize: 13.sp,
              color: valueColor ?? MosaedColors.textPrimary,
            ),
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
        style: getMediumStyle(fontSize: 12.sp, color: MosaedColors.textPrimary),
      ),
    );
  }
}
