import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../../core/widgets/orders_shimmer.dart';
import '../../custom_service/data/custom_service_repository.dart';
import '../../custom_service/data/models/custom_service_models.dart';
import '../../custom_service/presentation/custom_request_detail_screen.dart';
import '../../orders/data/booking_model.dart';
import '../../orders/data/order_model.dart';
import '../../orders/presentation/order_details_screen.dart';
import '../../services/data/services_repository.dart';

enum _OrdersFilter {
  today,
  all,
  pending,
  accepted,
  rejected,
  withdrawn,
  published,
  completed,
}

extension _OrdersFilterX on _OrdersFilter {
  String get labelKey {
    switch (this) {
      case _OrdersFilter.today:
        return 'mosaedOrdersFilterToday';
      case _OrdersFilter.all:
        return 'mosaedOrdersFilterAll';
      case _OrdersFilter.pending:
        return 'mosaedOrdersFilterPending';
      case _OrdersFilter.accepted:
        return 'mosaedOrdersFilterAccepted';
      case _OrdersFilter.rejected:
        return 'mosaedOrdersFilterRejected';
      case _OrdersFilter.withdrawn:
        return 'mosaedOrdersFilterWithdrawn';
      case _OrdersFilter.published:
        return 'mosaedOrdersFilterPublished';
      case _OrdersFilter.completed:
        return 'mosaedOrdersFilterCompleted';
    }
  }

  String? get apiStatus {
    switch (this) {
      case _OrdersFilter.today:
      case _OrdersFilter.all:
        return null;
      case _OrdersFilter.pending:
        return 'pending';
      case _OrdersFilter.accepted:
        return 'accepted';
      case _OrdersFilter.rejected:
        return 'rejected';
      case _OrdersFilter.withdrawn:
        return 'withdrawn';
      case _OrdersFilter.published:
        return 'published';
      case _OrdersFilter.completed:
        return 'completed';
    }
  }

  bool get isToday => this == _OrdersFilter.today;
}

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => OrdersTabState();
}

class OrdersTabState extends State<OrdersTab> {
  List<ServiceOrder> _orders = [];
  bool _loading = true;
  String? _error;
  _OrdersFilter _filter = _OrdersFilter.today;

  static const _filters = _OrdersFilter.values;

  String get _todayIso {
    final now = DateTime.now();
    final local = DateTime(now.year, now.month, now.day);
    return DateFormat('yyyy-MM-dd').format(local);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> reload() => _load();

  Future<void> _selectFilter(_OrdersFilter filter) async {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final servicesRepo = context.read<ServicesRepository>();
      final customRepo = context.read<CustomServiceRepository>();

      final status = _filter.apiStatus;
      final today = _todayIso;
      final dateFrom = _filter.isToday ? today : null;
      final dateTo = _filter.isToday ? today : null;

      List<Booking> bookings = [];
      List<CustomRequest> customRequests = [];

      try {
        bookings = await servicesRepo.getBookings(
          status: status,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
      } on ServerFailure catch (e) {
        if (mounted) {
          AppFunctions.showsToast(e.errMessage, MosaedColors.danger, context);
        }
      }

      try {
        customRequests = await customRepo.getCustomRequests(
          status: status,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
      } on ServerFailure catch (_) {
        // Custom requests are optional in the orders list.
      }

      final orders = <ServiceOrder>[
        ...bookings.map((b) => b.toServiceOrder()),
        ...customRequests.map((r) => r.toServiceOrder()),
      ]..sort((a, b) => b.scheduledSlot.compareTo(a.scheduledSlot));

      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        _error = null;
      });
    } on ServerFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.errMessage;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'mosaedOrdersLoadError'.tr();
        _loading = false;
      });
    }
  }

  void _openOrder(ServiceOrder order) {
    if (order.isCustomRequest && order.bookingId != null) {
      AppFunctions.navigateTo(
        context,
        CustomRequestDetailScreen(
          requestId: order.bookingId!,
          initialOrder: order,
        ),
        PageTransitionType.rightToLeft,
      );
      return;
    }

    AppFunctions.navigateTo(
      context,
      OrderDetailsScreen(order: order),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
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
                    ],
                  ),
                ),
                if (!_loading)
                  IconButton(
                    onPressed: _load,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: MosaedColors.primary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            _OrdersFilterBar(
              filters: _filters,
              selected: _filter,
              onSelected: _selectFilter,
            ),
            SizedBox(height: 16.h),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const OrdersShimmer();

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48.sp, color: MosaedColors.textHint),
            SizedBox(height: 12.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 14.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('mosaedRetry'.tr()),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: MosaedColors.shieldBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 40.sp,
                color: MosaedColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'mosaedNoOrdersYet'.tr(),
              style: getBoldStyle(
                fontSize: 16.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'mosaedNoOrdersHint'.tr(),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: MosaedColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _OrderCard(
            order: _orders[index],
            onTap: () => _openOrder(_orders[index]),
          );
        },
      ),
    );
  }
}

class _OrdersFilterBar extends StatelessWidget {
  const _OrdersFilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<_OrdersFilter> filters;
  final _OrdersFilter selected;
  final ValueChanged<_OrdersFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          final isToday = filter.isToday;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(filter),
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: isToday ? 16.w : 14.w,
                  vertical: isToday ? 9.h : 8.h,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? (isSelected
                          ? MosaedColors.primary
                          : MosaedColors.shieldBg)
                      : isSelected
                          ? MosaedColors.primaryFixed
                          : MosaedColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(isToday ? 22.r : 20.r),
                  border: Border.all(
                    // اليوم: بوردر مميز دايمًا — الباقي عادي
                    color: isToday
                        ? MosaedColors.primary
                        : isSelected
                            ? MosaedColors.primaryContainer
                            : MosaedColors.border,
                    width: isToday ? 2.5 : 1,
                  ),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: MosaedColors.primary.withValues(
                              alpha: isSelected ? 0.28 : 0.14,
                            ),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isToday) ...[
                      Icon(
                        Icons.today_rounded,
                        size: 16.sp,
                        color: isSelected
                            ? Colors.white
                            : MosaedColors.primary,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      filter.labelKey.tr(),
                      style: getMediumStyle(
                        fontSize: isToday ? 13.sp : 12.sp,
                        color: isToday
                            ? (isSelected
                                ? Colors.white
                                : MosaedColors.primary)
                            : isSelected
                                ? MosaedColors.primary
                                : MosaedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final ServiceOrder order;
  final VoidCallback onTap;

  String _localized(String value) =>
      value.startsWith('mosaed') ? value.tr() : value;

  @override
  Widget build(BuildContext context) {
    final currency = 'mosaedCurrency'.tr();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: MosaedColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: MosaedColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: order.statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              ),
              child: Row(
                children: [
                  _StepDot(active: true, color: order.statusColor),
                  _StepLine(active: !order.isPending),
                  _StepDot(
                    active: order.hasWorkerArrived || order.isCompleted,
                    color: MosaedColors.primary,
                  ),
                  _StepLine(active: order.isCompleted),
                  _StepDot(
                    active: order.isCompleted,
                    color: MosaedColors.success,
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: order.statusColor.withValues(alpha: 0.15),
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
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          color: order.statusColor.withValues(alpha: 0.1),
                          child: order.serviceImage != null &&
                                  order.serviceImage!.isNotEmpty
                              ? Image.network(
                                  order.serviceImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.home_repair_service_rounded,
                                    color: order.statusColor,
                                  ),
                                )
                              : Icon(
                                  Icons.home_repair_service_rounded,
                                  color: order.statusColor,
                                  size: 28.sp,
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 3,
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
                            if (order.isCustomRequest) ...[
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: MosaedColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'mosaedCustomRequestBadge'.tr(),
                                  style: getMediumStyle(
                                    fontSize: 10.sp,
                                    color: MosaedColors.primary,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 4.h),
                            Text(
                              order.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getRegularStyle(
                                fontSize: 12.sp,
                                color: MosaedColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14.sp,
                                  color: MosaedColors.textHint,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    _localized(order.scheduledSlot),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getRegularStyle(
                                      fontSize: 11.sp,
                                      color: MosaedColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (order.isCustomRequest && order.agreedAmount <= 0)
                              Text(
                                order.statusKey.tr(),
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: getMediumStyle(
                                  fontSize: 11.sp,
                                  color: MosaedColors.textSecondary,
                                ),
                              )
                            else if (order.isCustomRequest)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${order.agreedAmount.toStringAsFixed(0)} $currency',
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getBoldStyle(
                                      fontSize: 15.sp,
                                      color: MosaedColors.primary,
                                    ),
                                  ),
                                  Text(
                                    order.statusKey.tr(),
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getMediumStyle(
                                      fontSize: 10.sp,
                                      color: MosaedColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (order.agreedAmount > 0)
                                    Text(
                                      '${order.agreedAmount.toStringAsFixed(0)} $currency',
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: getBoldStyle(
                                        fontSize: 15.sp,
                                        color: MosaedColors.primary,
                                      ),
                                    )
                                  else
                                    Text(
                                      'mosaedPriceSetByDashboard'.tr(),
                                      textAlign: TextAlign.end,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: getMediumStyle(
                                        fontSize: 11.sp,
                                        color: MosaedColors.textSecondary,
                                      ),
                                    ),
                                  if (order.isPriceProposed)
                                    Text(
                                      'mosaedPriceProposed'.tr(),
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: getMediumStyle(
                                        fontSize: 10.sp,
                                        color: MosaedColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            SizedBox(height: 4.h),
                            Icon(
                              Icons.chevron_left_rounded,
                              color: MosaedColors.textHint,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (order.hasWorkerArrived) ...[
                    SizedBox(height: 12.h),
                    _StatusBanner(
                      icon: Icons.engineering_rounded,
                      text: 'mosaedWorkerArrivedBanner'.tr(),
                      color: MosaedColors.primary,
                      background: MosaedColors.shieldBg,
                    ),
                  ],
                  if (order.isCompleted) ...[
                    SizedBox(height: 12.h),
                    if (order.needsPayment)
                      _StatusBanner(
                        icon: Icons.payments_outlined,
                        text: 'mosaedPaymentDueBanner'.tr(),
                        color: MosaedColors.danger,
                        background: MosaedColors.danger.withValues(alpha: 0.08),
                      ),
                    if (!order.needsPayment && order.paymentTime != null)
                      _StatusBanner(
                        icon: Icons.check_circle_outline_rounded,
                        text: _localized(order.paymentTime!),
                        color: MosaedColors.success,
                        background: MosaedColors.successBg,
                      ),
                    if (order.needsRating) ...[
                      SizedBox(height: 8.h),
                      _StatusBanner(
                        icon: Icons.star_outline_rounded,
                        text: 'mosaedRateNowBanner'.tr(),
                        color: const Color(0xFFF59E0B),
                        background: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: active ? color : MosaedColors.border,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 2.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: active ? MosaedColors.primary.withValues(alpha: 0.5) : MosaedColors.border,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: getMediumStyle(fontSize: 12.sp, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
