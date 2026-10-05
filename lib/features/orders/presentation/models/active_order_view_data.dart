import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/assets_manager.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../custom_service/data/models/custom_service_models.dart';
import '../../data/completion_form_model.dart';
import '../../data/order_model.dart';
import '../widgets/order_progress_stepper.dart';

class ActiveOrderBadgeData {
  const ActiveOrderBadgeData({
    required this.labelKey,
    this.color = MosaedColors.brand,
    this.backgroundColor = MosaedColors.brandTransparent,
  });

  final String labelKey;
  final Color color;
  final Color backgroundColor;
}

class ActiveOrderChipData {
  const ActiveOrderChipData({
    this.icon,
    this.svgAsset,
    required this.label,
    this.outlined = false,
    this.maxLabelWidth = 120,
  });

  final IconData? icon;
  final String? svgAsset;
  final String label;
  final bool outlined;
  final double maxLabelWidth;
}

class ActiveOrderCollaborationData {
  const ActiveOrderCollaborationData({
    this.price,
    required this.technicianName,
    this.technicianImage,
    this.technicianPhone,
    required this.notes,
  });

  final double? price;
  final String technicianName;
  final String? technicianImage;
  final String? technicianPhone;
  final String notes;
}

/// UI model shared by custom-request and service-booking detail screens.
class ActiveOrderViewData {
  const ActiveOrderViewData({
    required this.title,
    this.badge,
    this.dayLabel,
    this.chips = const [],
    required this.problemTitle,
    required this.problemDescription,
    this.serviceType,
    this.problemPhotos = const [],
    this.address,
    required this.scheduleLabel,
    required this.orderNumber,
    required this.collaboration,
    this.completion,
    this.showSparePartsDisclaimer = true,
    this.customerRating = 0,
    this.showCompletedBadge = false,
    this.hasAssignedProvider = true,
    this.isCatalogBooking = false,
    this.catalogStatusCompleted = false,
    this.visitCost,
  });

  final String title;
  final ActiveOrderBadgeData? badge;
  final String? dayLabel;
  final List<ActiveOrderChipData> chips;
  final String problemTitle;
  final String problemDescription;
  final String? serviceType;
  final List<String> problemPhotos;
  final String? address;
  final String scheduleLabel;
  final String orderNumber;
  final ActiveOrderCollaborationData collaboration;
  final CompletionForm? completion;
  final bool showSparePartsDisclaimer;
  final double customerRating;
  final bool showCompletedBadge;
  final bool hasAssignedProvider;
  final bool isCatalogBooking;
  final bool catalogStatusCompleted;
  final double? visitCost;

  bool get hasDeterminedPrice =>
      collaboration.price != null && collaboration.price! > 0;

  bool get isAwaitingPrice =>
      isCatalogBooking &&
      hasAssignedProvider &&
      !hasDeterminedPrice &&
      !catalogStatusCompleted &&
      (completion == null ||
          (completion!.needsArrivalConfirm && !completion!.hasStarted));

  bool get canConfirmArrival {
    if (!isCatalogBooking) {
      return completion == null || completion!.needsArrivalConfirm;
    }
    return catalogStatusCompleted &&
        (completion == null || completion!.needsArrivalConfirm);
  }

  ActiveOrderProgress get progress => ActiveOrderProgress(
        completion: completion,
        customerRating: customerRating,
        hasAssignedProvider: hasAssignedProvider,
        awaitingPrice: isAwaitingPrice,
        canConfirmArrival: canConfirmArrival,
      );

  ActiveOrderBadgeData? get displayBadge {
    if (showCompletedBadge) {
      return const ActiveOrderBadgeData(
        labelKey: 'mosaedOrderCompletedBadge',
        color: Color(0xFF43A047),
        backgroundColor: Color(0xFFE8F5E9),
      );
    }
    return badge;
  }

  static String formatScheduleLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'mosaedNotAvailableYet'.tr();
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = day.difference(today).inDays;
    final dayText = diff == 0
        ? 'mosaedToday'.tr()
        : diff == 1
            ? 'mosaedTomorrow'.tr()
            : DateFormat('d MMM').format(dt);
    if (dt.hour == 0 && dt.minute == 0) return dayText;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'م' : 'ص';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$dayText، $hour:$mm $period';
  }

  static String relativeTimeAgo(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'mosaedJustNow'.tr();
    if (diff.inMinutes < 60) {
      return 'mosaedMinutesAgo'.tr(args: ['${diff.inMinutes}']);
    }
    if (diff.inHours < 24) {
      return 'mosaedHoursAgo'.tr(args: ['${diff.inHours}']);
    }
    return 'mosaedDaysAgo'.tr(args: ['${diff.inDays}']);
  }

  static String relativeDayLabel(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return 'mosaedToday'.tr();
    final dt = DateTime.tryParse(createdAt)?.toLocal();
    if (dt == null) return 'mosaedToday'.tr();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'mosaedToday'.tr();
    if (diff == -1) return 'mosaedYesterday'.tr();
    return DateFormat('d MMM').format(dt);
  }

  static String formatOrderNumber(String id, {String prefix = 'INK'}) {
    if (id.length > 8) {
      return '$prefix-${id.substring(0, 8).toUpperCase()}';
    }
    return '$prefix-${id.toUpperCase()}';
  }

  static bool serviceOrderHasAssignedProvider(ServiceOrder order) {
    final name = order.workerName.trim();
    if (name.isNotEmpty && name != 'mosaedWorkerPending') return true;
    final s = (order.rawStatus ?? '').toLowerCase().trim();
    return s.contains('assign') ||
        s.contains('accepted') ||
        s.contains('arriv') ||
        s.contains('progress') ||
        s.contains('active') ||
        s.contains('start');
  }

  factory ActiveOrderViewData.fromCustomRequest({
    required CustomRequest request,
    required CustomOffer? acceptedOffer,
    required CompletionForm? completion,
    double customerRating = 0,
  }) {
    final scheduleLabel = formatScheduleLabel(request.scheduledDate);
    final providerName = acceptedOffer?.providerName?.trim() ??
        request.providerName?.trim() ??
        'mosaedNotAvailableYet'.tr();
    final notes = completion?.notes?.trim().isNotEmpty == true
        ? completion!.notes!
        : acceptedOffer?.note?.trim().isNotEmpty == true
            ? acceptedOffer!.note!
            : request.description;

    final finished = completion?.hasFinished == true;
    final paidOrCash = completion?.isPaymentPaid == true ||
        completion?.isAwaitingCashPayment == true;

    return ActiveOrderViewData(
      title: request.title.isNotEmpty
          ? request.title
          : 'mosaedCustomServiceTitle'.tr(),
      badge: const ActiveOrderBadgeData(labelKey: 'mosaedCustomRequestBadge'),
      dayLabel: relativeDayLabel(request.createdAt),
      chips: [
        if (request.specializationName?.trim().isNotEmpty == true)
          ActiveOrderChipData(
            svgAsset: ImageAssets.orders,
            label: request.specializationName!.trim(),
          ),
        if (scheduleLabel.isNotEmpty)
          ActiveOrderChipData(
            svgAsset: ImageAssets.calendar03,
            label: scheduleLabel,
          ),
      ],
      problemTitle: request.title,
      problemDescription: request.description,
      serviceType: request.specializationName,
      problemPhotos: request.allImages,
      address: request.addressText,
      scheduleLabel: scheduleLabel,
      orderNumber: formatOrderNumber(request.id),
      collaboration: ActiveOrderCollaborationData(
        price: acceptedOffer?.price,
        technicianName: providerName,
        technicianImage: acceptedOffer?.providerImage,
        notes: notes,
      ),
      completion: completion,
      customerRating: customerRating,
      showCompletedBadge: finished && (paidOrCash || customerRating > 0),
      hasAssignedProvider: true,
    );
  }

  factory ActiveOrderViewData.fromServiceOrder({
    required ServiceOrder order,
    required CompletionForm? completion,
    double customerRating = 0,
  }) {
    final hasProvider = serviceOrderHasAssignedProvider(order);
    final price = order.agreedAmount > 0 ? order.agreedAmount : null;
    final awaitingPrice = hasProvider &&
        price == null &&
        !order.isCompleted &&
        (completion == null ||
            (completion.needsArrivalConfirm && !completion.hasStarted));

    final scheduleLabel = catalogScheduleLabel(order);

    final location = order.locationText.startsWith('mosaed')
        ? order.locationText.tr()
        : order.locationText;

    final workerName = !hasProvider
        ? 'mosaedTechnicianNotSelected'.tr()
        : order.workerName.startsWith('mosaed')
            ? order.workerName.tr()
            : order.workerName;

    ActiveOrderBadgeData? badge;
    if (!hasProvider) {
      badge = const ActiveOrderBadgeData(
        labelKey: 'mosaedWaitingTechnicianSelection',
      );
    } else if (awaitingPrice) {
      badge = const ActiveOrderBadgeData(
        labelKey: 'mosaedWaitingPriceDetermination',
      );
    } else if (order.isCompleted &&
        (completion == null || completion.needsArrivalConfirm)) {
      badge = const ActiveOrderBadgeData(
        labelKey: 'mosaedWaitingArrivalConfirm',
      );
    }

    return ActiveOrderViewData(
      title: order.serviceTitle,
      badge: badge,
      dayLabel: relativeDayLabel(order.createdAt),
      chips: [
        if (location.isNotEmpty)
          ActiveOrderChipData(
            svgAsset: ImageAssets.locationFill,
            label: location,
            outlined: true,
            maxLabelWidth: 160,
          ),
        if (scheduleLabel.isNotEmpty)
          ActiveOrderChipData(
            svgAsset: ImageAssets.calendar03,
            label: scheduleLabel,
          ),
      ],
      problemTitle: order.serviceTitle,
      problemDescription: catalogDescription(order),
      address: location,
      scheduleLabel: scheduleLabel,
      orderNumber: formatOrderNumber(order.bookingId ?? order.id),
      collaboration: ActiveOrderCollaborationData(
        price: price,
        technicianName: workerName,
        technicianImage: order.workerImage,
        technicianPhone: order.workerPhone,
        notes: catalogDescription(order),
      ),
      completion: completion,
      showSparePartsDisclaimer: false,
      customerRating: customerRating,
      showCompletedBadge: order.isCompleted ||
          customerRating > 0 ||
          completion?.isPaymentPaid == true,
      hasAssignedProvider: hasProvider,
      isCatalogBooking: true,
      catalogStatusCompleted: order.isCompleted,
      visitCost: order.serviceVisitCost,
    );
  }

  static String catalogScheduleLabel(ServiceOrder order) {
    final raw = order.scheduledSlot;
    final base = raw.startsWith('mosaed')
        ? raw.tr()
        : formatScheduleLabel(raw);
    final dt = DateTime.tryParse(raw)?.toLocal();
    final hasTime = dt != null && (dt.hour != 0 || dt.minute != 0);
    if (hasTime) return base;
    final time = timeFromNotes(order.notes);
    if (time == null || base.contains(time)) return base;
    if (base == 'mosaedNotAvailableYet'.tr()) return time;
    return '$base، $time';
  }

  static String? timeFromNotes(String notes) {
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*([صم])').firstMatch(notes);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    return '$hour:${match.group(2)} ${match.group(3)}';
  }

  static String catalogDescription(ServiceOrder order) {
    final notes = order.notes.trim();
    if (notes.isEmpty || notes.startsWith('mosaed')) {
      return order.serviceTitle;
    }
    if (notes.contains('الموعد') ||
        notes.toLowerCase().contains('appointment')) {
      return order.serviceTitle;
    }
    return notes;
  }
}
