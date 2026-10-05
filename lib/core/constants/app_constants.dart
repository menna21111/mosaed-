class AppConstants {
  /// غيّر الـ base URL حسب الـ API الخاص بك
  static const String baseUrl = 'https://api.mosa3ed.net';
  static const String appVersion = '2.4.1';
  static const String userType = 'customer';
  static const String otpSend = '/api/accounts/otp/send/';
  static const String otpVerify = '/api/accounts/otp/verify/';
  static const String customerRegister = '/api/accounts/customer/register/';
  static const String customerProfile = '/api/accounts/customer/profile/';
  static const String logout = 'logout/';
  static const String biometricRegister = '/api/accounts/biometric/register/';
  static const String biometricLogin = '/api/accounts/biometric/login/';
  static const String tokenRefresh = 'auth/tokens/refresh/';

  static const String existedServices = '/api/existedservices/existed/';
  static String existedServiceDetail(String id) =>
      '/api/existedservices/existed/$id/';
  static String serviceProviders(String serviceId) =>
      '/api/existedservices/services/$serviceId/providers/';
  static String servicePreviousWorks(String serviceId) =>
      '/api/existedservices/services/$serviceId/previous-works/';
  static const String bookings = '/api/existedservices/bookings/';
  static String bookingDetail(String id) => '/api/existedservices/bookings/$id/';
  /// Completion details for an existing-service booking.
  static String bookingCompletionForm(String bookingId) =>
      '/api/existedservices/bookings/$bookingId/completion/';
  static const String validateCoupon = '/api/existedservices/coupons/validate/';
  static const String customRequests = '/api/custom_services/custom-requests/';
  /// App intro / onboarding slides (public).
  static const String onboard = '/api/custom_services/onboarding/';
  static String customRequestDetail(String id) =>
      '/api/custom_services/custom-requests/$id/';
  static String customRequestOffers(String requestId) =>
      '/api/custom_services/custom-requests/$requestId/offers/';
  static String acceptCustomOffer(String requestId, String offerId) =>
      '/api/custom_services/custom-requests/$requestId/offers/$offerId/accept/';
  static String rejectCustomOffer(String requestId, String offerId) =>
      '/api/custom_services/custom-requests/$requestId/offers/$offerId/reject/';
  static String customRequestProviderArrived(String requestId) =>
      '/api/custom_services/custom-requests/$requestId/provider-arrived/';
  static String bookingProviderArrived(String bookingId) =>
      '/api/existedservices/bookings/$bookingId/provider-arrived/';
  static String cancelCustomRequest(String requestId) =>
      '/api/custom_services/custom-requests/$requestId/cancel/';
  /// Completion details for a custom request.
  static String customRequestCompletion(String requestId) =>
      '/api/custom_services/custom-requests/$requestId/completion/';
  static String customRequestChat(String requestId) =>
      '/api/custom_services/custom-requests/$requestId/chat/';
  static String customRequestChatRead(String requestId) =>
      '/api/custom_services/custom-requests/$requestId/chat/read/';
  static const String customRequestConversations =
      '/api/custom_services/custom-requests/conversations/';

  // ── Payments (customer) — Base: /api/payments/ ─────────────────────
  /// Direct payment request detail.
  /// الـ id من completion.payment_request_id أو الإشعار
  static String paymentDetail(String paymentRequestId) =>
      '/api/payments/$paymentRequestId/';

  /// Resolve payment by booking when opening payment from order details
  /// (not from a push notification that already carries payment_request_id).
  static String paymentByBooking(String bookingId) =>
      '/api/payments/by-booking/$bookingId/';

  static String selectPaymentMethod(String paymentRequestId) =>
      '/api/payments/payments/$paymentRequestId/select-method/';

  static String confirmCashPayment(String paymentRequestId) =>
      '/api/payments/$paymentRequestId/confirm-cash/';

  /// Loyalty points — custom requests only (not existed-service bookings).
  static String applyPaymentPoints(String paymentRequestId) =>
      '/api/payments/$paymentRequestId/apply-points/';
  static String removePaymentPoints(String paymentRequestId) =>
      '/api/payments/$paymentRequestId/remove-points/';
  static const String customerPointsWallet =
      '/api/payments/customer/points-wallet/';

  /// React Moyasar checkout (WebView).
  /// `{FRONTEND}/payments/{payment_request_id}?token={access_token}`
  /// الصفحة نفسها بتتولى اختيار أونلاين/كاش + Moyasar + 3DS.
  static const String paymentsFrontendUrl =
      'https://mosaeddashboard-production.up.railway.app';

  // ── Notifications ──────────────────────────────────────────────────
  static const String notifications = '/api/custom_services/notifications/';
  static const String notificationsUnreadCount =
      '/api/custom_services/notifications/unread-count/';
  static String notificationRead(String id) =>
      '/api/custom_services/notifications/$id/read/';
  static const String notificationsMarkAllRead =
      '/api/custom_services/notifications/mark-all-read/';
  static const String deviceTokens = '/api/custom_services/device-tokens/';

  static String get wsBaseUrl {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final includePort = uri.hasPort &&
        uri.port != 0 &&
        uri.port != 443 &&
        uri.port != 80;
    final port = includePort ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$port';
  }

  static List<String> notificationSocketUrls(String accessToken) => [
        '$wsBaseUrl/ws/notifications/?token=$accessToken',
        '$wsBaseUrl/ws/notifications/?access_token=$accessToken',
      ];

  static List<String> chatSocketUrls(String requestId, String accessToken) => [
        '$wsBaseUrl/ws/chat/$requestId/?token=$accessToken',
        '$wsBaseUrl/ws/chat/$requestId/?access_token=$accessToken',
        '$wsBaseUrl/ws/customer/chat/$requestId/?token=$accessToken',
        '$wsBaseUrl/ws/customer/chat/$requestId/?access_token=$accessToken',
      ];

  static const String specializations = '/api/accounts/specializations/';

  static const String cloudinaryCloudName = 'dftpzis0y';
  static const String cloudinaryUploadPreset = 'mosaed_customer';
  static const String cloudinaryCustomRequestsFolder = 'custom_requests';
  static String get cloudinaryImageUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  /// مؤقتًا لحد ما يتظبط Cloudinary upload preset
  static const String customRequestPlaceholderImage =
      'https://res.cloudinary.com/dftpzis0y/image/upload/v1782039707/services/erfger_ktaiib.png';

  static const String customerAddresses = '/api/accounts/customer/addresses/';
  static String customerAddress(String id) =>
      '/api/accounts/customer/addresses/$id/';
  static String deleteAddress(String id) => customerAddress(id);
  static const String cities = '/api/accounts/cities/';
  static const String regions = '/api/accounts/regions';

  static const String googleMapsApiKey =
      'AIzaSyBcqYSQUB84VBJOwAqgyMmHlfGfW3Yl68A';

  static const String defaultAddressIdKey = 'default_address_id';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String biometricTokenKey = 'biometric_token';
  static const String deviceIdKey = 'device_id';
  static const String userNameKey = 'user_name';
  static const String phoneNumberKey = 'phone_number';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String isLoggedInKey = 'is_logged_in';
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String locationSetupDoneKey = 'location_setup_done';
  static const String notifMessagesKey = 'notif_messages';
  static const String notifOffersKey = 'notif_offers';
  static const String notifOrderStatusKey = 'notif_order_status';
  static const String notifTechnicianKey = 'notif_technician';
  static const String notifPaymentKey = 'notif_payment';
  static const String userCityKey = 'user_city';
  static const String userDistrictKey = 'user_district';
  static const String userStreetKey = 'user_street';
  static const String userLocationDetailsKey = 'user_location_details';
}
