class AppConstants {
  /// غيّر الـ base URL حسب الـ API الخاص بك
  static const String baseUrl = 'https://mosaed-production.up.railway.app';

  static const String appVersion = '2.4.1';
  static const String userType = 'customer';

  static const String otpSend = '/api/accounts/otp/send/';
  static const String otpVerify = '/api/accounts/otp/verify/';
  static const String customerRegister = 'customer/register/';
  static const String logout = 'logout/';
  static const String biometricRegister = '/api/accounts/biometric/register/';
  static const String biometricLogin = '/api/accounts/biometric/login/';
  static const String tokenRefresh = 'auth/tokens/refresh/';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String biometricTokenKey = 'biometric_token';
  static const String deviceIdKey = 'device_id';
  static const String userNameKey = 'user_name';
  static const String phoneNumberKey = 'phone_number';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String isLoggedInKey = 'is_logged_in';
  static const String locationSetupDoneKey = 'location_setup_done';
  static const String userCityKey = 'user_city';
  static const String userDistrictKey = 'user_district';
  static const String userStreetKey = 'user_street';
  static const String userLocationDetailsKey = 'user_location_details';
}
