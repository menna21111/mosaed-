import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_helper.dart';
import '../../../core/network/failure.dart';
import 'models/onboard_slide.dart';

class OnboardingRepository {
  List<dynamic> _parseList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in [
        'results',
        'data',
        'items',
        'onboard',
        'onboarding',
        'screens',
        'slides',
        'pages',
      ]) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }

  Future<List<OnboardSlide>> getOnboardSlides() async {
    try {
      final response = await DioHelper.getData(
        url: AppConstants.onboard,
        isWithoutToken: true,
      );
      final slides = _parseList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(OnboardSlide.fromJson)
          .where((s) => s.isActive)
          .where(
            (s) =>
                s.title.trim().isNotEmpty ||
                (s.titleAr?.trim().isNotEmpty ?? false) ||
                (s.titleEn?.trim().isNotEmpty ?? false) ||
                s.description.trim().isNotEmpty ||
                (s.imageUrl?.isNotEmpty ?? false),
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return slides;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      throw ServerFailure.fromDioError(e);
    }
  }
}
