import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../caching/cach_helper.dart';
import '../constants/app_constants.dart';
import 'auth_intercaptor.dart';

class DioHelper {
  static Dio? dio;
  static Future<String?>? _refreshFuture;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (!kReleaseMode) {
      dio?.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    dio?.interceptors.add(AuthInterceptor());
  }

  static Future<void> headers({bool isWithoutToken = false}) async {
    final accessToken = await getAccessToken();

    dio?.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (!isWithoutToken && accessToken != null)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static Future<String?> getAccessToken() async {
    if (_refreshFuture != null) return _refreshFuture;

    final accessToken =
        CacheHelper().getDataString(key: AppConstants.accessTokenKey);
    final refreshToken =
        CacheHelper().getDataString(key: AppConstants.refreshTokenKey);

    if (accessToken == null) return null;

    if (JwtDecoder.isExpired(accessToken)) {
      if (refreshToken == null) return null;
      _refreshFuture = _performRefresh(refreshToken);
      final result = await _refreshFuture;
      _refreshFuture = null;
      return result;
    }
    return accessToken;
  }

  static Future<String?> _performRefresh(String refreshToken) async {
    try {
      final response = await dio!.post(
        AppConstants.tokenRefresh,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data['access'] != null) {
        final newAccess = response.data['access'].toString();
        final newRefresh = response.data['refresh']?.toString() ?? refreshToken;

        await CacheHelper().saveData(
          key: AppConstants.accessTokenKey,
          value: newAccess,
        );
        await CacheHelper().saveData(
          key: AppConstants.refreshTokenKey,
          value: newRefresh,
        );

        dio?.options.headers['Authorization'] = 'Bearer $newAccess';
        return newAccess;
      }
      return null;
    } catch (e) {
      log('Refresh token error: $e');
      return null;
    }
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    bool isWithoutToken = false,
  }) async {
    await headers(isWithoutToken: isWithoutToken);
    return dio!.get(url, queryParameters: query);
  }

  static Future<Response> postData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
    bool isWithoutToken = false,
  }) async {
    await headers(isWithoutToken: isWithoutToken);
    return dio!.post(url, data: data, queryParameters: query);
  }

  static Future<Response> postDataWithoutAuth({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
  }) {
    return postData(
      url: url,
      data: data,
      query: query,
      isWithoutToken: true,
    );
  }

  static Future<Response> putData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
  }) async {
    await headers();
    return dio!.put(url, data: data, queryParameters: query);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    await headers();
    return dio!.delete(url, queryParameters: query);
  }
}
