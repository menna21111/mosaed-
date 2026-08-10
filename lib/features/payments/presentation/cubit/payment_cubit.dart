import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../data/models/customer_points_wallet.dart';
import '../../data/models/payment_request.dart';
import '../../data/payments_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._repository) : super(const PaymentInitial());

  final PaymentsRepository _repository;

  Future<CustomerPointsWallet?> loadPointsWallet() async {
    try {
      return await _repository.getPointsWallet();
    } on ServerFailure {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<PaymentRequest?> applyPoints({
    required String paymentRequestId,
    required num points,
  }) async {
    emit(const PaymentPointsBusy());
    try {
      final payment = await _repository.applyPoints(
        paymentRequestId: paymentRequestId,
        points: points,
      );
      emit(const PaymentInitial());
      return payment;
    } on ServerFailure catch (e) {
      emit(PaymentFailure(e.errMessage));
      return null;
    } catch (_) {
      emit(const PaymentFailure('حدث خطأ غير متوقع'));
      return null;
    }
  }

  Future<PaymentRequest?> removePoints(String paymentRequestId) async {
    emit(const PaymentPointsBusy());
    try {
      final payment = await _repository.removePoints(paymentRequestId);
      emit(const PaymentInitial());
      return payment;
    } on ServerFailure catch (e) {
      emit(PaymentFailure(e.errMessage));
      return null;
    } catch (_) {
      emit(const PaymentFailure('حدث خطأ غير متوقع'));
      return null;
    }
  }

  /// Resolve payment id then open WebView — no GET /payments/<id>/ upfront.
  Future<String?> resolveBookingPaymentId({
    String? paymentRequestId,
    String? bookingId,
  }) async {
    emit(const PaymentResolving());
    try {
      final id = await _repository.resolveBookingPaymentId(
        paymentRequestId: paymentRequestId,
        bookingId: bookingId,
      );
      if (id == null || id.isEmpty) {
        emit(const PaymentFailure('تعذر العثور على طلب الدفع'));
        return null;
      }
      emit(const PaymentInitial());
      return id;
    } on ServerFailure catch (e) {
      emit(PaymentFailure(e.errMessage));
      return null;
    } catch (_) {
      emit(const PaymentFailure('حدث خطأ غير متوقع'));
      return null;
    }
  }

  @Deprecated('Use resolveBookingPaymentId')
  Future<PaymentRequest?> resolveBookingPayment({
    String? paymentRequestId,
    String? bookingId,
  }) async {
    final id = await resolveBookingPaymentId(
      paymentRequestId: paymentRequestId,
      bookingId: bookingId,
    );
    if (id == null) return null;
    return PaymentRequest(
      id: id,
      requestId: bookingId?.trim() ?? '',
      amount: 0,
      status: 'awaiting_method',
    );
  }

  Future<PaymentRequest?> refreshPayment(String paymentRequestId) async {
    try {
      return await _repository.getPaymentDetail(paymentRequestId);
    } catch (_) {
      return null;
    }
  }

  Future<PaymentRequest?> selectPaymentMethod({
    required String paymentMethod,
    String? paymentRequestId,
    String? bookingId,
  }) async {
    final method = paymentMethod.trim().toLowerCase();
    emit(const PaymentSelecting());

    try {
      var id = paymentRequestId?.trim() ?? '';
      if (id.isEmpty) {
        id = await _repository.resolveBookingPaymentId(
              paymentRequestId: null,
              bookingId: bookingId,
            ) ??
            '';
      }

      if (id.isEmpty) {
        emit(const PaymentFailure('تعذر العثور على طلب الدفع'));
        return null;
      }

      final payment = await _repository.selectPaymentMethod(
        paymentRequestId: id,
        paymentMethod: method,
      );
      emit(PaymentMethodSelected(payment: payment, method: method));
      return payment;
    } on ServerFailure catch (e) {
      emit(PaymentFailure(e.errMessage));
      return null;
    } catch (_) {
      emit(const PaymentFailure('حدث خطأ غير متوقع'));
      return null;
    }
  }

  Future<String> buildOnlinePaymentUrl(String paymentRequestId) =>
      _repository.buildOnlinePaymentUrl(paymentRequestId);

  void reset() => emit(const PaymentInitial());
}
