import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../orders/data/order_model.dart';
import '../../orders/presentation/order_details_screen.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = ServiceOrder.sampleOrders();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'mosaedOrders'.tr(),
              style: getBoldStyle(
                fontSize: 22.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'mosaedOrdersSubtitle'.tr(),
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return InkWell(
                    onTap: () {
                      AppFunctions.navigateTo(
                        context,
                        OrderDetailsScreen(order: order),
                        PageTransitionType.rightToLeft,
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: MosaedColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: MosaedColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: order.statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.home_repair_service_outlined,
                              color: order.statusColor,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.serviceKey.tr(),
                                  style: getBoldStyle(
                                    fontSize: 15.sp,
                                    color: MosaedColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  order.id,
                                  style: getRegularStyle(
                                    fontSize: 12.sp,
                                    color: MosaedColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: order.statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              order.statusKey.tr(),
                              style: getMediumStyle(
                                fontSize: 11.sp,
                                color: order.statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
