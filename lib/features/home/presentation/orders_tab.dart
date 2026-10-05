import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/network/failure.dart';
import '../../../core/widgets/mosaed_pill_tabs.dart';
import '../../../core/widgets/orders_shimmer.dart';
import '../../custom_service/data/custom_service_repository.dart';
import '../../custom_service/data/models/custom_service_models.dart';
import '../../custom_service/presentation/custom_request_detail_screen.dart';
import '../../orders/data/booking_model.dart';
import '../../orders/presentation/order_details_screen.dart';
import '../../services/data/services_repository.dart';
import '../../services/presentation/widgets/address_chrome.dart';
import 'widgets/custom_request_order_card.dart';
import 'widgets/orders_list_bits.dart';

enum _OrdersSegment { services, custom }

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => OrdersTabState();
}

class OrdersTabState extends State<OrdersTab> {
  List<Booking> _bookings = [];
  List<CustomRequest> _customRequests = [];
  bool _loading = true;
  String? _error;
  _OrdersSegment _segment = _OrdersSegment.custom;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final servicesRepo = context.read<ServicesRepository>();
      final customRepo = context.read<CustomServiceRepository>();

      final results = await Future.wait([
        servicesRepo.getBookings().catchError((_) => <Booking>[]),
        customRepo.getCustomRequests().catchError((_) => <CustomRequest>[]),
      ]);

      var bookings = results[0] as List<Booking>;
      var customRequests = results[1] as List<CustomRequest>;

      customRequests.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      bookings.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _customRequests = customRequests;
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

  void _openBooking(Booking booking) {
    final order = booking.toServiceOrder();
    AppFunctions.navigateTo(
      context,
      OrderDetailsScreen(order: order),
      PageTransitionType.rightToLeft,
    );
  }

  void _openCustom(CustomRequest request) {
    AppFunctions.navigateTo(
      context,
      CustomRequestDetailScreen(
        requestId: request.id,
        initialOrder: request.toServiceOrder(),
      ),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MosaedColors.background,
      child: SafeArea(
        child: Column(
          children: [
            MosaedPageTitle(
              LocaleKeys.mosaedMyOrders.tr(),
              showDivider: true,
            ),
            SizedBox(height: 12.h),
            _OrdersSegmentBar(
              segment: _segment,
              onChanged: (s) => setState(() => _segment = s),
            ),
            SizedBox(height: 8.h),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: OrdersShimmer(),
      );
    }

    if (_error != null) {
      return OrdersLoadError(message: _error!, onRetry: _load);
    }

    if (_segment == _OrdersSegment.custom) {
      if (_customRequests.isEmpty) {
        return OrdersEmptyState(
          message: LocaleKeys.mosaedNoCustomRequestsYet.tr(),
          onRefresh: _load,
        );
      }

      return RefreshIndicator(
        onRefresh: _load,
        color: MosaedColors.brand,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          itemCount: _customRequests.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final request = _customRequests[index];
            return CustomRequestOrderCard(
              request: request,
              onTap: () => _openCustom(request),
            );
          },
        ),
      );
    }

    if (_bookings.isEmpty) {
      return OrdersEmptyState(
        message: LocaleKeys.mosaedNoServicesYet.tr(),
        onRefresh: _load,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: MosaedColors.brand,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        itemCount: _bookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return ServiceBookingOrderCard(
            order: booking.toServiceOrder(),
            onTap: () => _openBooking(booking),
          );
        },
      ),
    );
  }
}

class _OrdersSegmentBar extends StatelessWidget {
  const _OrdersSegmentBar({
    required this.segment,
    required this.onChanged,
  });

  final _OrdersSegment segment;
  final ValueChanged<_OrdersSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: MosaedPillTabs(
        labels: [
          LocaleKeys.mosaedCustomRequestsTab.tr(),
          LocaleKeys.mosaedServicesTab.tr(),
        ],
        selectedIndex: segment == _OrdersSegment.custom ? 0 : 1,
        onChanged: (index) => onChanged(
          index == 0 ? _OrdersSegment.custom : _OrdersSegment.services,
        ),
      ),
    );
  }
}

