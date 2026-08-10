import 'package:dio/dio.dart';

import '../../../core/caching/cach_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_helper.dart';
import '../../../core/network/failure.dart';
import 'models/customer_points_wallet.dart';
import 'models/payment_request.dart';

class PaymentsRepository {
  String _extractError(dynamic data) => ServerFailure.extractApiMessage(data);

  PaymentRequest? _parse(dynamic data) {
    if (data is Map && data.isNotEmpty) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['payment_request'];
      if (nested is Map) {
        return PaymentRequest.fromJson(Map<String, dynamic>.from(nested));
      }
      if (map.containsKey('id') ||
          map.containsKey('status') ||
          map.containsKey('payment_request_id')) {
        final parsed = PaymentRequest.fromJson(map);
        if (parsed.id.isEmpty) return null;
        // by-booking may omit status — treat as awaiting method choice.
        if (parsed.status.trim().isEmpty) {
          return PaymentRequest(
            id: parsed.id,
            requestId: parsed.requestId,
            requestTitle: parsed.requestTitle,
            amount: parsed.amount,
            providerShare: parsed.providerShare,
            platformShare: parsed.platformShare,
            pointsUsed: parsed.pointsUsed,
            pointsDiscountAmount: parsed.pointsDiscountAmount,
            finalAmount: parsed.finalAmount,
            paymentMethod: parsed.paymentMethod,
            status: 'awaiting_method',
            createdAt: parsed.createdAt,
            paidAt: parsed.paidAt,
          );
        }
        return parsed;
      }
    }
    return null;
  }

  /// `GET /api/payments/customer/points-wallet/`
  Future<CustomerPointsWallet> getPointsWallet() async {
    try {
      final response = await DioHelper.getData(
        url: AppConstants.customerPointsWallet,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CustomerPointsWallet.fromJson(data);
      }
      throw ServerFailure('تعذر تحميل محفظة النقاط');
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  /// `POST /api/payments/<id>/apply-points/`
  Future<PaymentRequest> applyPoints({
    required String paymentRequestId,
    required num points,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.applyPaymentPoints(paymentRequestId),
        data: {'points': points},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }
      final parsed = _parse(response.data);
      if (parsed != null) return parsed;
      final refreshed = await getPaymentDetail(paymentRequestId);
      if (refreshed != null) return refreshed;
      throw ServerFailure(_extractError(response.data));
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  /// `POST /api/payments/<id>/remove-points/`
  Future<PaymentRequest> removePoints(String paymentRequestId) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.removePaymentPoints(paymentRequestId),
        data: const {},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }
      final parsed = _parse(response.data);
      if (parsed != null) return parsed;
      final refreshed = await getPaymentDetail(paymentRequestId);
      if (refreshed != null) return refreshed;
      throw ServerFailure(_extractError(response.data));
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  /// `GET /api/payments/<payment_request_id>/`
  /// الـ id بيجي من completion أو الإشعار.
  Future<PaymentRequest?> getPaymentDetail(String paymentRequestId) async {
    try {
      final response = await DioHelper.getData(
        url: AppConstants.paymentDetail(paymentRequestId),
      );
      return _parse(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerFailure.fromDioError(e);
    }
  }

  /// `GET /api/payments/by-booking/<booking_id>/`
  /// للحالة اللي العميل بيفتح الدفع من صفحة الحجز ومش معاه payment_request_id.
  Future<PaymentRequest?> getPaymentByBooking(String bookingId) async {
    final id = bookingId.trim();
    if (id.isEmpty) return null;
    try {
      final response = await DioHelper.getData(
        url: AppConstants.paymentByBooking(id),
      );
      return _parse(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerFailure.fromDioError(e);
    }
  }

  /// Resolve payment id for an existed-service booking.
  ///
  /// Prefer [paymentRequestId] from completion/notification — do **not** call
  /// `GET /payments/<id>/` before opening the WebView (that endpoint can 404
  /// while the dashboard page still works). Only call `by-booking/` when the
  /// id is missing.
  Future<String?> resolveBookingPaymentId({
    String? paymentRequestId,
    String? bookingId,
  }) async {
    final fromCompletion = paymentRequestId?.trim();
    if (fromCompletion != null && fromCompletion.isNotEmpty) {
      return fromCompletion;
    }
    final bid = bookingId?.trim();
    if (bid == null || bid.isEmpty) return null;
    final byBooking = await getPaymentByBooking(bid);
    return byBooking?.id;
  }

  @Deprecated('Use resolveBookingPaymentId — avoids GET /payments/<id>/ before WebView')
  Future<PaymentRequest?> resolveBookingPayment({
    String? paymentRequestId,
    String? bookingId,
  }) async {
    final id = await resolveBookingPaymentId(
      paymentRequestId: paymentRequestId,
      bookingId: bookingId,
    );
    if (id == null || id.isEmpty) return null;
    return PaymentRequest(
      id: id,
      requestId: bookingId?.trim() ?? '',
      amount: 0,
      status: 'awaiting_method',
    );
  }

  Future<PaymentRequest?> getPaymentIfReady(
    String? paymentRequestIdFromCompletion,
  ) async {
    final id = paymentRequestIdFromCompletion?.trim();
    if (id == null || id.isEmpty) return null;
    return getPaymentDetail(id);
  }

  @Deprecated('Use getPaymentIfReady')
  Future<PaymentRequest?> getBookingPaymentIfReady(
    String? paymentRequestIdFromCompletion,
  ) =>
      getPaymentIfReady(paymentRequestIdFromCompletion);

  /// `POST /api/payments/<payment_request_id>/select-method/`
  /// Body: `{ "payment_method": "online" | "cash" }`
  Future<PaymentRequest> selectPaymentMethod({
    required String paymentRequestId,
    required String paymentMethod,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: AppConstants.selectPaymentMethod(paymentRequestId),
        data: {'payment_method': paymentMethod},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(_extractError(response.data));
      }
      final parsed = _parse(response.data);
      if (parsed != null) return parsed;

      final refreshed = await getPaymentDetail(paymentRequestId);
      if (refreshed != null) return refreshed;

      return PaymentRequest(
        id: paymentRequestId,
        requestId: '',
        amount: 0,
        status: paymentMethod == 'cash'
            ? 'awaiting_cash_confirmation'
            : 'awaiting_gateway_payment',
        paymentMethod: paymentMethod,
      );
    } on DioException catch (e) {
      throw ServerFailure.fromDioError(e);
    }
  }

  /// Dashboard checkout URL — same JWT the app uses in Authorization.
  ///
  /// `https://mosaeddashboard-production.up.railway.app/payments/<id>?token=<access_token>`
  Future<String> buildOnlinePaymentUrl(String paymentRequestId) async {
    // Prefer refreshed access token (same source as Dio Authorization header).
    final token = await DioHelper.getAccessToken() ??
        CacheHelper().getDataString(key: AppConstants.accessTokenKey) ??
        '';
    if (token.isEmpty) {
      throw ServerFailure('تعذر قراءة توكن المستخدم — سجّل الدخول مرة أخرى');
    }

    final base = AppConstants.paymentsFrontendUrl.replaceAll(RegExp(r'/$'), '');
    final id = paymentRequestId.trim();
    // Full JWT in query — do not truncate.
    final url = '$base/payments/$id?token=${Uri.encodeComponent(token)}';

    // ignore: avoid_print
    print('[Payment] WebView URL (full) => $url');
    return url;
  }
}
