import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/mosaed_colors.dart';
import '../../../orders/data/order_model.dart';

class Specialization {
  const Specialization({required this.id, required this.name});

  final String id;
  final String name;

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class CustomRequestPayload {
  const CustomRequestPayload({
    required this.specializationId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.addressId,
    this.imageFiles = const [],
  });

  final String specializationId;
  final String title;
  final String description;
  final String scheduledDate;
  final String addressId;

  /// صور محلية تُرفع كـ multipart files.
  final List<File> imageFiles;
}

class CustomOffer {
  const CustomOffer({
    required this.id,
    required this.price,
    this.note,
    this.status,
    this.providerId,
    this.providerName,
    this.providerImage,
    this.providerRating,
    this.providerJobsCount,
    this.providerCity,
    this.providerBio,
    this.distanceKm,
    this.createdAt,
  });

  final String id;
  final double price;
  final String? note;
  final String? status;
  final String? providerId;
  final String? providerName;
  final String? providerImage;
  final double? providerRating;
  final int? providerJobsCount;
  final String? providerCity;
  final String? providerBio;
  final double? distanceKm;
  final String? createdAt;

  bool get isPending {
    final s = status?.toLowerCase().trim() ?? '';
    return s.isEmpty || s == 'pending' || s == 'submitted';
  }

  bool get isAccepted {
    final s = status?.toLowerCase().trim() ?? '';
    return s.contains('accept');
  }

  bool get isRejected {
    final s = status?.toLowerCase().trim() ?? '';
    return s.contains('reject') || s.contains('declin');
  }

  /// Customer can chat with the provider once the offer is accepted.
  bool get canChat => isAccepted;

  factory CustomOffer.fromJson(Map<String, dynamic> json) {
    final provider = _asMap(json['provider']) ??
        _asMap(json['service_provider']) ??
        _asMap(json['worker']);
    final status = json['status']?.toString();
    final acceptedFlag = json['is_accepted'] == true ||
        json['is_accepted']?.toString().toLowerCase() == 'true';

    final city = provider?['city']?.toString() ??
        provider?['city_name']?.toString() ??
        json['provider_city']?.toString();
    final country = provider?['country']?.toString() ??
        provider?['country_name']?.toString();
    String? cityLabel = city;
    if (city != null &&
        city.isNotEmpty &&
        country != null &&
        country.isNotEmpty) {
      cityLabel = '$city - $country';
    }

    return CustomOffer(
      id: json['id']?.toString() ?? '',
      price: _toDouble(
        json['final_price'] ??
            json['provider_price'] ??
            json['price'] ??
            json['amount'] ??
            json['total_price'] ??
            json['total'],
      ),
      note: json['note']?.toString() ??
          json['message']?.toString() ??
          json['provider_note']?.toString(),
      status: acceptedFlag && (status == null || status.isEmpty)
          ? 'accepted'
          : status,
      providerId: provider?['id']?.toString() ??
          json['provider_id']?.toString(),
      providerName: provider?['name']?.toString() ??
          provider?['full_name']?.toString() ??
          json['provider_name']?.toString(),
      providerImage: provider?['image']?.toString() ??
          provider?['avatar']?.toString() ??
          provider?['photo']?.toString() ??
          json['provider_image']?.toString(),
      providerRating: _toDoubleOrNull(
        provider?['average_rating'] ??
            provider?['rating'] ??
            json['average_rating'] ??
            json['provider_rating'],
      ),
      providerJobsCount: int.tryParse(
        (provider?['jobs_count'] ??
                provider?['completed_jobs'] ??
                provider?['services_count'] ??
                provider?['total_reviews'] ??
                json['total_reviews'] ??
                json['provider_jobs_count'] ??
                '')
            .toString(),
      ),
      providerCity: cityLabel,
      providerBio: provider?['bio']?.toString() ??
          provider?['about']?.toString() ??
          provider?['description']?.toString() ??
          json['provider_bio']?.toString(),
      distanceKm: _toDoubleOrNull(
        json['distance_km'] ??
            json['distance'] ??
            provider?['distance_km'] ??
            provider?['distance'],
      ),
      createdAt: json['created_at']?.toString(),
    );
  }

  CustomOffer copyWith({
    String? status,
    String? note,
  }) {
    return CustomOffer(
      id: id,
      price: price,
      note: note ?? this.note,
      status: status ?? this.status,
      providerId: providerId,
      providerName: providerName,
      providerImage: providerImage,
      providerRating: providerRating,
      providerJobsCount: providerJobsCount,
      providerCity: providerCity,
      providerBio: providerBio,
      distanceKm: distanceKm,
      createdAt: createdAt,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static double _toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}

class CustomRequest {
  const CustomRequest({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.images = const [],
    required this.rawStatus,
    required this.status,
    this.scheduledDate,
    this.specializationName,
    this.addressText,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.offersCount,
    this.providerArrivedAt,
    this.acceptedOffer,
    this.acceptedProviderId,
    this.providerName,
    this.offers = const [],
  });

  final String id;
  final String title;
  final String description;
  final String? image;
  final List<String> images;
  final String rawStatus;
  final OrderStatus status;
  final String? scheduledDate;
  final String? specializationName;
  final String? addressText;
  final String? createdAt;
  final String? updatedAt;
  final String? expiresAt;
  final int? offersCount;
  final String? providerArrivedAt;
  final CustomOffer? acceptedOffer;
  final String? acceptedProviderId;
  final String? providerName;
  final List<CustomOffer> offers;

  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (image != null && image!.trim().isNotEmpty) return [image!];
    return const [];
  }

  String? get coverImage =>
      allImages.isNotEmpty ? allImages.first : image;

  bool get isAwaitingOffers {
    final s = rawStatus.toLowerCase();
    return s.isEmpty ||
        s.contains('publish') ||
        s.contains('pend') ||
        s.contains('open') ||
        s.contains('await');
  }

  bool get isWaitingTechnician {
    final s = rawStatus.toLowerCase();
    return hasAcceptedOffer &&
        providerArrivedAt == null &&
        !s.contains('progress') &&
        !s.contains('active') &&
        !s.contains('in_progress') &&
        status == OrderStatus.pending;
  }

  bool get hasAcceptedOffer {
    final s = rawStatus.toLowerCase();
    return acceptedOffer != null ||
        (acceptedProviderId != null && acceptedProviderId!.isNotEmpty) ||
        s.contains('accept') ||
        s.contains('assign') ||
        s.contains('confirm');
  }

  bool get canChat => hasAcceptedOffer;

  String get displayStatusKey {
    final s = rawStatus.toLowerCase().trim();
    if (s.contains('cancel')) return 'mosaedOrderCancelled';
    if (s.contains('complete') || s.contains('done') || s.contains('finish')) {
      return 'mosaedOrderCompletedShort';
    }
    if (s.contains('arriv') ||
        s.contains('progress') ||
        s.contains('active') ||
        s.contains('in_progress') ||
        status == OrderStatus.workerArrived) {
      return 'mosaedOrderInProgress';
    }
    if (isWaitingTechnician || s.contains('accept') || s.contains('assign')) {
      return 'mosaedWaitingTechnician';
    }
    if (isAwaitingOffers) return 'mosaedReceivingOffers';
    return status.statusKey;
  }

  Color get displayStatusColor {
    final key = displayStatusKey;
    if (key == 'mosaedOrderCompletedShort') return const Color(0xFF43A047);
    if (key == 'mosaedOrderInProgress') return const Color(0xFF5C6BC0);
    if (key == 'mosaedWaitingTechnician') return const Color(0xFF8E24AA);
    if (key == 'mosaedReceivingOffers') return MosaedColors.brand;
    if (key == 'mosaedOrderCancelled') return MosaedColors.danger;
    return MosaedColors.brand;
  }

  Color get displayStatusBg {
    if (displayStatusKey == 'mosaedReceivingOffers') {
      return MosaedColors.brandTransparent;
    }
    return displayStatusColor.withValues(alpha: 0.12);
  }

  bool get canConfirmProviderArrived {
    if (status == OrderStatus.completed ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.workerArrived) {
      return false;
    }
    return hasAcceptedOffer && providerArrivedAt == null;
  }

  /// Cancel is allowed until the request is finished or already cancelled.
  bool get canCancel {
    final s = rawStatus.toLowerCase().trim();
    if (s.contains('cancel')) return false;
    if (s.contains('complete') || s.contains('done') || s.contains('finish')) {
      return false;
    }
    return status != OrderStatus.completed && status != OrderStatus.cancelled;
  }

  CustomOffer? resolveAcceptedOffer(List<CustomOffer> offers) {
    if (acceptedOffer != null) return acceptedOffer;

    final acceptedByStatus =
        offers.where((o) => o.isAccepted).toList(growable: false);
    if (acceptedByStatus.isNotEmpty) {
      return _asAcceptedOffer(acceptedByStatus.first);
    }

    if (acceptedProviderId != null && acceptedProviderId!.isNotEmpty) {
      for (final offer in offers) {
        if (offer.providerId == acceptedProviderId) {
          return _asAcceptedOffer(offer);
        }
      }
    }

    if (hasAcceptedOffer && offers.length == 1) {
      return _asAcceptedOffer(offers.first);
    }

    return null;
  }

  factory CustomRequest.fromJson(Map<String, dynamic> json) {
    final address = _asMap(json['address']);
    final rawStatus = json['status']?.toString() ?? '';
    final specialization = json['specialization'];
    final specializationMap = _asMap(specialization);
    final acceptedOfferRaw = _asMap(json['accepted_offer']) ??
        _asMap(json['selected_offer']) ??
        _asMap(json['offer']);
    final acceptedProviderRaw = json['accepted_provider'];
    final acceptedProviderId = acceptedProviderRaw is Map
        ? acceptedProviderRaw['id']?.toString()
        : acceptedProviderRaw?.toString();
    final provider = _asMap(json['provider']) ??
        (acceptedProviderRaw is Map ? _asMap(acceptedProviderRaw) : null) ??
        _asMap(acceptedOfferRaw?['provider']);
    final arrivedRaw = json['provider_arrived_at'] ??
        json['arrived_at'] ??
        json['provider_arrived'];

    final parsedImages = _parseImages(json);
    final parsedOffers = _parseOffers(json);

    return CustomRequest(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ??
          (parsedImages.isNotEmpty ? parsedImages.first : null),
      images: parsedImages,
      rawStatus: rawStatus,
      status: _mapStatus(rawStatus, arrivedRaw),
      scheduledDate: json['scheduled_date']?.toString(),
      specializationName: specialization is String
          ? specialization
          : specializationMap?['name']?.toString() ??
              json['specialization_name']?.toString() ??
              json['specialization_id']?.toString(),
      addressText: _formatAddress(address, json),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      offersCount: int.tryParse(
            json['offers_count']?.toString() ??
                json['quotes_count']?.toString() ??
                '',
          ) ??
          (parsedOffers.isEmpty ? null : parsedOffers.length),
      providerArrivedAt: arrivedRaw?.toString(),
      acceptedOffer: acceptedOfferRaw != null
          ? _asAcceptedOffer(CustomOffer.fromJson(acceptedOfferRaw))
          : null,
      acceptedProviderId: acceptedProviderId?.trim().isNotEmpty == true
          ? acceptedProviderId!.trim()
          : null,
      providerName: provider?['name']?.toString() ??
          provider?['full_name']?.toString() ??
          json['provider_name']?.toString(),
      offers: parsedOffers,
    );
  }

  ServiceOrder toServiceOrder({CustomOffer? accepted}) {
    final shortId = id.length > 8 ? '#${id.substring(0, 8)}' : '#$id';
    final offer = accepted ?? acceptedOffer;
    final worker = providerName?.trim().isNotEmpty == true
        ? providerName!
        : offer?.providerName?.trim().isNotEmpty == true
            ? offer!.providerName!
            : specializationName?.trim().isNotEmpty == true
                ? specializationName!
                : 'mosaedCustomRequestPending';

    return ServiceOrder(
      id: shortId,
      bookingId: id,
      serviceTitle: title.isNotEmpty ? title : 'mosaedCustomServiceTitle'.tr(),
      serviceImage: coverImage,
      status: status,
      rawStatus: rawStatus,
      type: OrderType.customRequest,
      workerName: worker,
      workerRating: offer?.providerRating ?? 0,
      workerJobsCount: offer?.providerJobsCount ?? offersCount ?? 0,
      agreedAmount: offer?.price ?? 0,
      paymentReceived: false,
      scheduledSlot: scheduledDate != null
          ? _formatDate(scheduledDate!)
          : 'mosaedNotAvailableYet',
      locationText: addressText?.trim().isNotEmpty == true
          ? addressText!
          : 'mosaedNotAvailableYet'.tr(),
      arrivedAt: providerArrivedAt != null
          ? _formatDateTime(providerArrivedAt!)
          : 'mosaedNotArrivedYet',
      finishedAt: 'mosaedNotFinishedYet',
      toolsUsed: const [],
      materialsUsed: const [],
      customerRating: 0,
      notes: description.trim().isNotEmpty ? description : 'mosaedNoNotes'.tr(),
      createdAt: createdAt,
    );
  }

  static List<String> _parseImages(Map<String, dynamic> json) {
    final out = <String>[];
    final raw = json['images'] ?? json['photos'] ?? json['image_urls'];
    if (raw is List) {
      for (final e in raw) {
        if (e is String && e.trim().isNotEmpty) {
          out.add(e.trim());
        } else if (e is Map) {
          final u = e['url'] ?? e['image'] ?? e['path'] ?? e['src'];
          if (u != null && u.toString().trim().isNotEmpty) {
            out.add(u.toString().trim());
          }
        }
      }
    }
    final single = json['image']?.toString().trim();
    if (single != null &&
        single.isNotEmpty &&
        !out.contains(single)) {
      out.insert(0, single);
    }
    return out;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<CustomOffer> _parseOffers(Map<String, dynamic> json) {
    final raw =
        json['offers'] ?? json['quotes'] ?? json['price_offers'] ?? json['offer_list'];
    if (raw is! List) return const [];
    final out = <CustomOffer>[];
    for (final item in raw) {
      final map = _asMap(item);
      if (map == null) continue;
      final offer = CustomOffer.fromJson(map);
      if (offer.id.isNotEmpty) out.add(offer);
    }
    return out;
  }

  /// Ensure nested accepted offers unlock chat even if API omits status.
  static CustomOffer _asAcceptedOffer(CustomOffer offer) {
    if (offer.isAccepted) return offer;
    return offer.copyWith(status: 'accepted');
  }

  static OrderStatus _mapStatus(String raw, dynamic arrivedRaw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('cancel')) return OrderStatus.cancelled;
    if (s.contains('complete') || s.contains('done') || s.contains('finish')) {
      return OrderStatus.completed;
    }
    if (arrivedRaw != null ||
        s.contains('arriv') ||
        s.contains('progress') ||
        s.contains('active') ||
        s.contains('in_progress')) {
      return OrderStatus.workerArrived;
    }
    // accepted = تم قبول العرض — لسه الفني ما وصلش
    return OrderStatus.pending;
  }

  static String _formatAddress(
    Map<String, dynamic>? address,
    Map<String, dynamic> json,
  ) {
    if (address != null) {
      final parts = <String>[
        if (address['label'] != null && address['label'].toString().trim().isNotEmpty)
          address['label'].toString(),
        if (address['city_name'] != null &&
            address['city_name'].toString().trim().isNotEmpty)
          address['city_name'].toString(),
        if (address['region_name'] != null &&
            address['region_name'].toString().trim().isNotEmpty)
          address['region_name'].toString(),
        if (address['district'] != null &&
            address['district'].toString().trim().isNotEmpty)
          address['district'].toString(),
        if (address['street'] != null &&
            address['street'].toString().trim().isNotEmpty)
          address['street'].toString(),
        if (address['building_no'] != null &&
            address['building_no'].toString().trim().isNotEmpty)
          '${'mosaedBuildingNo'.tr()} ${address['building_no']}',
        if (address['floor_no'] != null &&
            address['floor_no'].toString().trim().isNotEmpty)
          '${'mosaedFloorNo'.tr()} ${address['floor_no']}',
        if (address['apartment_no'] != null &&
            address['apartment_no'].toString().trim().isNotEmpty)
          '${'mosaedApartmentNo'.tr()} ${address['apartment_no']}',
      ].where((p) => p.trim().isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.join(' • ');
    }
    return [
      if (json['city'] != null && json['city'].toString().trim().isNotEmpty)
        json['city'].toString(),
      if (json['region'] != null && json['region'].toString().trim().isNotEmpty)
        json['region'].toString(),
      if (json['district'] != null &&
          json['district'].toString().trim().isNotEmpty)
        json['district'].toString(),
      if (json['address_text'] != null &&
          json['address_text'].toString().trim().isNotEmpty)
        json['address_text'].toString(),
    ].join(' • ');
  }

  static String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('yyyy-MM-dd').format(dt.toLocal());
    } catch (_) {
      return raw;
    }
  }

  static String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('yyyy-MM-dd • HH:mm').format(dt.toLocal());
    } catch (_) {
      return raw;
    }
  }
}
