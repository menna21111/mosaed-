import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/caching/cach_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_helper.dart';
import '../../../core/network/failure.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/device_service.dart';
import 'models/auth_session.dart';

class AuthRepository {
  String _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) return data['detail'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['error_message'] != null) {
        return data['error_message'].toString();
      }
      if (data['non_field_errors'] is List &&
          (data['non_field_errors'] as List).isNotEmpty) {
        return data['non_field_errors'].first.toString();
      }
      for (final entry in data.entries) {
        if (entry.value is List && (entry.value as List).isNotEmpty) {
          return '${entry.key}: ${(entry.value as List).first}';
        }
        if (entry.value is String && entry.value.toString().isNotEmpty) {
          return entry.value.toString();
        }
      }
    }
    return 'حدث خطأ، حاول مرة أخرى';
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      final response = await DioHelper.postDataWithoutAuth(
        url: AppConstants.otpSend,
        data: {
          'phone_number': phoneNumber,
          'user_type': AppConstants.userType,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    String? deviceToken,
  }) async {
    try {
      final response = await DioHelper.postDataWithoutAuth(
        url: AppConstants.otpVerify,
        data: {
          'phone_number': phoneNumber,
          'user_type': AppConstants.userType,
          'otp_code': otpCode,
          if (deviceToken != null && deviceToken.isNotEmpty)
            'device_token': deviceToken,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }

      final session = AuthSession.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {},
      );

      await _persistSession(
        session.copyWith(phoneNumber: phoneNumber),
      );
      return session;
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<void> registerCustomer({
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      final response = await DioHelper.postDataWithoutAuth(
        url: AppConstants.customerRegister,
        data: {
          'name': name,
          'phone_number': phoneNumber,
          'email': email,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }

      await CacheHelper().saveData(
        key: AppConstants.userNameKey,
        value: name,
      );
      await CacheHelper().saveData(
        key: AppConstants.phoneNumberKey,
        value: phoneNumber,
      );
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<String> registerBiometric() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final response = await DioHelper.postData(
        url: AppConstants.biometricRegister,
        data: {'device_id': deviceId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final biometricToken = data['biometric_token']?.toString();
      if (biometricToken == null || biometricToken.isEmpty) {
        throw ServerFailure('mosaedBiometricTokenNotReceived'.tr());
      }

      await CacheHelper().saveData(
        key: AppConstants.biometricTokenKey,
        value: biometricToken,
      );

      return biometricToken;
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<AuthSession> loginWithBiometric({String? deviceToken}) async {
    final biometricToken = CacheHelper().getDataString(
      key: AppConstants.biometricTokenKey,
    );

    if (biometricToken == null || biometricToken.isEmpty) {
      throw ServerFailure('mosaedBiometricNoToken'.tr());
    }

    final authenticated = await BiometricService.authenticate(
      reason: 'mosaedBiometricPromptReason'.tr(),
    );

    if (!authenticated) {
      throw ServerFailure('mosaedBiometricAuthFailed'.tr());
    }

    try {
      final deviceId = await DeviceService.getDeviceId();
      final response = await DioHelper.postDataWithoutAuth(
        url: AppConstants.biometricLogin,
        data: {
          'biometric_token': biometricToken,
          'device_id': deviceId,
          if (deviceToken != null && deviceToken.isNotEmpty)
            'device_token': deviceToken,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }

      final session = AuthSession.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {},
      );

      await _persistSession(session);
      return session;
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  Future<void> logout() async {
    final refresh = CacheHelper().getDataString(
      key: AppConstants.refreshTokenKey,
    );

    if (refresh != null && refresh.isNotEmpty) {
      try {
        await DioHelper.postData(
          url: AppConstants.logout,
          data: {'refresh': refresh},
        );
      } catch (_) {}
    }

    await clearSession();
  }

  Future<void> clearSession() async {
    await Future.wait([
      CacheHelper().removeData(key: AppConstants.accessTokenKey),
      CacheHelper().removeData(key: AppConstants.refreshTokenKey),
      CacheHelper().removeData(key: AppConstants.biometricTokenKey),
      CacheHelper().removeData(key: AppConstants.isLoggedInKey),
      CacheHelper().removeData(key: AppConstants.biometricEnabledKey),
    ]);
  }

  bool get isLoggedIn =>
      CacheHelper().getData(key: AppConstants.isLoggedInKey) == true;

  bool get isBiometricEnabled =>
      CacheHelper().getData(key: AppConstants.biometricEnabledKey) == true;

  bool get hasBiometricToken {
    final token = CacheHelper().getDataString(key: AppConstants.biometricTokenKey);
    return token != null && token.isNotEmpty;
  }

  bool get canUseBiometricLogin =>
      isBiometricEnabled && hasBiometricToken;

  Future<bool> canUseBiometricLoginOnDevice() async {
    if (!canUseBiometricLogin) return false;
    return BiometricService.isFingerprintAvailable();
  }

  Future<({bool success, String? error})> setupBiometricLogin({
    required String promptMessage,
  }) async {
    final authenticated = await BiometricService.authenticate(
      reason: promptMessage,
    );
    if (!authenticated) {
      return (success: false, error: 'mosaedBiometricAuthCancelled'.tr());
    }

    try {
      await registerBiometric();
    } on ServerFailure catch (e) {
      return (success: false, error: e.errMessage);
    }

    await enableBiometric();
    return (success: true, error: null);
  }

  String? get storedPhone =>
      CacheHelper().getDataString(key: AppConstants.phoneNumberKey);

  String get userName =>
      CacheHelper().getDataString(key: AppConstants.userNameKey) ??
      'user'.tr();

  Future<void> enableBiometric() async {
    await CacheHelper().saveData(
      key: AppConstants.biometricEnabledKey,
      value: true,
    );
  }

  Future<bool> enableBiometricLogin() async {
    if (!hasBiometricToken) return false;
    await enableBiometric();
    return true;
  }

  Future<void> disableBiometric() async {
    await CacheHelper().removeData(key: AppConstants.biometricEnabledKey);
  }

  Future<void> _persistSession(AuthSession session) async {
    if (session.accessToken != null) {
      await CacheHelper().saveData(
        key: AppConstants.accessTokenKey,
        value: session.accessToken!,
      );
    }
    if (session.refreshToken != null) {
      await CacheHelper().saveData(
        key: AppConstants.refreshTokenKey,
        value: session.refreshToken!,
      );
    }
    if (session.biometricToken != null) {
      await CacheHelper().saveData(
        key: AppConstants.biometricTokenKey,
        value: session.biometricToken!,
      );
    }
    if (session.userName != null) {
      await CacheHelper().saveData(
        key: AppConstants.userNameKey,
        value: session.userName!,
      );
    }
    if (session.phoneNumber != null) {
      await CacheHelper().saveData(
        key: AppConstants.phoneNumberKey,
        value: session.phoneNumber!,
      );
    }
    await CacheHelper().saveData(key: AppConstants.isLoggedInKey, value: true);
  }
}

extension _AuthSessionCopy on AuthSession {
  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    String? biometricToken,
    String? userName,
    String? phoneNumber,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      biometricToken: biometricToken ?? this.biometricToken,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
