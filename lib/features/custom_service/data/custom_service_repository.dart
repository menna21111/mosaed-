import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_helper.dart';
import '../../../core/network/failure.dart';
import '../../orders/data/completion_form_model.dart';
import 'models/custom_service_models.dart';

class CustomServiceRepository {
  List<dynamic> _parseList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in [
        'results',
        'data',
        'items',
        'offers',
        'quotes',
        'price_offers',
        'custom_requests',
        'requests',
      ]) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }

  Future<List<Specialization>> getSpecializations() async {
    try {
      final response = await DioHelper.getData(url: AppConstants.specializations);
      return _parseList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(Specialization.fromJson)
          .where((s) => s.id.isNotEmpty && s.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<CustomRequest> createCustomRequest(CustomRequestPayload payload) async {
    try {
      final map = <String, dynamic>{
        'specialization_id': payload.specializationId,
        'title': payload.title,
        'description': payload.description,
        'scheduled_date': payload.scheduledDate,
        'address_id': payload.addressId,
      };

      if (payload.imageFiles.isNotEmpty) {
        // Separate MultipartFile instances — reusing the same instance
        // in both `image` and `images` causes "already been finalized".
        final first = payload.imageFiles.first;
        final firstName = first.path.split(RegExp(r'[/\\]')).last;
        map['image'] = await MultipartFile.fromFile(
          first.path,
          filename: firstName.isNotEmpty ? firstName : 'image.jpg',
        );

        final images = <MultipartFile>[];
        for (var i = 0; i < payload.imageFiles.length; i++) {
          final file = payload.imageFiles[i];
          final name = file.path.split(RegExp(r'[/\\]')).last;
          images.add(
            await MultipartFile.fromFile(
              file.path,
              filename: name.isNotEmpty ? name : 'image_$i.jpg',
            ),
          );
        }
        map['images'] = images;
      }

      final response = await DioHelper.postMultipart(
        url: AppConstants.customRequests,
        data: FormData.fromMap(map),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(
          ServerFailure.extractApiMessage(response.data),
        );
      }
      final raw = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final nested = raw['data'];
      final data = nested is Map<String, dynamic> ? nested : raw;
      return CustomRequest.fromJson(data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<List<CustomRequest>> getCustomRequests({
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final query = <String, dynamic>{
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'date_from': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'date_to': dateTo.trim(),
      };
      final response = await DioHelper.getData(
        url: AppConstants.customRequests,
        query: query.isEmpty ? null : query,
      );
      return _parseList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CustomRequest.fromJson)
          .where((r) => r.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  @Deprecated('Use getCustomRequests')
  Future<List<CustomRequest>> getPublishedCustomRequests() =>
      getCustomRequests();


  Future<CustomRequest> getCustomRequestDetail(String requestId) async {
    try {
      final response = await DioHelper.getData(
        url: AppConstants.customRequestDetail(requestId),
      );
      final raw = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final nested = raw['data'];
      final data = nested is Map<String, dynamic>
          ? Map<String, dynamic>.from(nested)
          : Map<String, dynamic>.from(raw);
      if (data['offers'] == null && raw['offers'] != null) {
        data['offers'] = raw['offers'];
      }
      return CustomRequest.fromJson(data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<List<CustomOffer>> getCustomRequestOffers(String requestId) async {
    try {
      final response = await DioHelper.getData(
        url: AppConstants.customRequestOffers(requestId),
      );
      return _parseList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CustomOffer.fromJson)
          .where((o) => o.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<CustomRequest> acceptOffer({
    required String requestId,
    required String offerId,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.acceptCustomOffer(requestId, offerId),
        data: const {},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(
          ServerFailure.extractApiMessage(response.data),
        );
      }
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (data.isEmpty) {
        return getCustomRequestDetail(requestId);
      }
      return CustomRequest.fromJson(data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<void> rejectOffer({
    required String requestId,
    required String offerId,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.rejectCustomOffer(requestId, offerId),
        data: const {},
      );
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerFailure(
          ServerFailure.extractApiMessage(response.data),
        );
      }
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<CustomRequest> confirmProviderArrived(String requestId) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.customRequestProviderArrived(requestId),
        data: const {},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(
          ServerFailure.extractApiMessage(response.data),
        );
      }
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (data.isEmpty) {
        return getCustomRequestDetail(requestId);
      }
      // Response may be the request or the completion form.
      if (data.containsKey('started_at') ||
          data.containsKey('is_finished') ||
          data.containsKey('booking_id') ||
          data.containsKey('media')) {
        return getCustomRequestDetail(requestId);
      }
      return CustomRequest.fromJson(data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<CustomRequest> cancelCustomRequest(String requestId) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.cancelCustomRequest(requestId),
        data: const {},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(
          ServerFailure.extractApiMessage(response.data),
        );
      }
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (data.isEmpty) {
        return getCustomRequestDetail(requestId);
      }
      return CustomRequest.fromJson(data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<CompletionForm?> getCustomRequestCompletion(String requestId) async {
    try {
      final response = await DioHelper.getData(
        url: AppConstants.customRequestCompletion(requestId),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data.isNotEmpty) {
        return CompletionForm.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerFailure.fromDioError(e);
    }
  }
}
