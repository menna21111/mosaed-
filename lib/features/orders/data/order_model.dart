import 'package:flutter/material.dart';

import '../../../core/constants/mosaed_colors.dart';
import 'booking_model.dart';
import 'completion_form_model.dart';

enum OrderStatus {
  pending,
  workerArrived,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get statusKey {
    switch (this) {
      case OrderStatus.pending:
        return 'mosaedOrderPending';
      case OrderStatus.workerArrived:
        return 'mosaedOrderActive';
      case OrderStatus.completed:
        return 'mosaedOrderDone';
      case OrderStatus.cancelled:
        return 'mosaedOrderCancelled';
    }
  }

  Color get statusColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFF59E0B);
      case OrderStatus.workerArrived:
        return MosaedColors.primary;
      case OrderStatus.completed:
        return MosaedColors.success;
      case OrderStatus.cancelled:
        return MosaedColors.danger;
    }
  }

  bool get showArrival => this == OrderStatus.workerArrived;
  bool get showPaymentAndRating => this == OrderStatus.completed;
}

enum OrderType {
  booking,
  customRequest,
}

class ServiceOrder {
  const ServiceOrder({
    required this.id,
    this.bookingId,
    required this.serviceTitle,
    this.serviceImage,
    required this.status,
    this.rawStatus,
    this.type = OrderType.booking,
    required this.workerName,
    this.workerPhone,
    required this.workerRating,
    required this.workerJobsCount,
    required this.agreedAmount,
    this.serviceVisitCost,
    this.discountAmount,
    required this.paymentReceived,
    required this.scheduledSlot,
    required this.locationText,
    required this.arrivedAt,
    required this.finishedAt,
    required this.toolsUsed,
    required this.materialsUsed,
    this.bookingItems = const [],
    required this.customerRating,
    required this.notes,
    this.paymentTime,
    this.complaintSubmitted = false,
    this.couponCode,
    this.createdAt,
  });

  final String id;
  final String? bookingId;
  final String serviceTitle;
  final String? serviceImage;
  final OrderStatus status;

  /// الحالة الخام من الـ API (مثل accepted / published).
  final String? rawStatus;
  final OrderType type;
  final String workerName;
  final String? workerPhone;
  final double workerRating;
  final int workerJobsCount;
  final double agreedAmount;
  final double? serviceVisitCost;
  final double? discountAmount;
  final bool paymentReceived;
  final String? paymentTime;
  final String scheduledSlot;
  final String locationText;
  final String arrivedAt;
  final String finishedAt;
  final List<String> toolsUsed;
  final List<String> materialsUsed;
  final List<BookingItem> bookingItems;
  final double customerRating;
  final String notes;
  final bool complaintSubmitted;
  final String? couponCode;
  final String? createdAt;

  /// مفتاح الترجمة المطابق لحالة الـ API الفعلية.
  String get statusKey {
    final s = (rawStatus ?? '').toLowerCase().trim();
    if (s == 'price_proposed' || s.contains('price_proposed')) {
      return 'mosaedPriceProposed';
    }
    if (s.contains('accept')) return 'mosaedRequestAccepted';
    if (s.contains('cancel')) return 'mosaedOrderCancelled';
    if (s.contains('complete') || s.contains('done') || s.contains('finish')) {
      return 'mosaedOrderDone';
    }
    if (s.contains('arriv') ||
        s.contains('progress') ||
        s.contains('active') ||
        s.contains('in_progress') ||
        s.contains('assign') ||
        s.contains('confirm')) {
      return 'mosaedOrderActive';
    }
    if (s.contains('publish') ||
        s.contains('pend') ||
        s.contains('open') ||
        s.contains('await')) {
      return 'mosaedAwaitingOffers';
    }
    return status.statusKey;
  }

  Color get statusColor {
    final s = (rawStatus ?? '').toLowerCase().trim();
    if (s == 'price_proposed' || s.contains('price_proposed')) {
      return MosaedColors.primary;
    }
    return status.statusColor;
  }

  bool get isCustomRequest => type == OrderType.customRequest;
  bool get isBooking => type == OrderType.booking;
  bool get isPending => status == OrderStatus.pending;
  bool get hasWorkerArrived => status == OrderStatus.workerArrived;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isPriceProposed {
    final s = (rawStatus ?? '').toLowerCase().trim();
    return s == 'price_proposed' || s.contains('price_proposed');
  }
  bool get needsRating => isCompleted && customerRating <= 0;
  bool get needsPayment => isCompleted && !paymentReceived;

  ServiceOrder copyWith({
    OrderStatus? status,
    String? rawStatus,
    double? customerRating,
    bool? paymentReceived,
    String? paymentTime,
    bool? complaintSubmitted,
    String? arrivedAt,
    String? finishedAt,
  }) {
    return ServiceOrder(
      id: id,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      serviceImage: serviceImage,
      status: status ?? this.status,
      rawStatus: rawStatus ?? this.rawStatus,
      type: type,
      workerName: workerName,
      workerPhone: workerPhone,
      workerRating: workerRating,
      workerJobsCount: workerJobsCount,
      agreedAmount: agreedAmount,
      serviceVisitCost: serviceVisitCost,
      discountAmount: discountAmount,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      paymentTime: paymentTime ?? this.paymentTime,
      scheduledSlot: scheduledSlot,
      locationText: locationText,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      toolsUsed: toolsUsed,
      materialsUsed: materialsUsed,
      bookingItems: bookingItems,
      customerRating: customerRating ?? this.customerRating,
      notes: notes,
      complaintSubmitted: complaintSubmitted ?? this.complaintSubmitted,
      couponCode: couponCode,
      createdAt: createdAt,
    );
  }

  /// يحدّث حالة الطلب من completion (المصدر الأدق لتقدّم الشغل).
  ServiceOrder applyingCompletion(CompletionForm? completion) {
    if (completion == null) return this;

    OrderStatus nextStatus = status;
    String? nextRaw = rawStatus;
    if (completion.hasFinished) {
      nextStatus = OrderStatus.completed;
      nextRaw = 'completed';
    } else if (completion.isProviderArrived || completion.hasStarted) {
      nextStatus = OrderStatus.workerArrived;
      nextRaw = 'provider_arrived';
    }

    final paid = paymentReceived ||
        (completion.paymentStatus?.toLowerCase().contains('paid') == true);

    return copyWith(
      status: nextStatus,
      rawStatus: nextRaw,
      arrivedAt: completion.startedAtFormatted ?? arrivedAt,
      finishedAt: completion.finishedAtFormatted ?? finishedAt,
      paymentReceived: paid,
    );
  }
}

