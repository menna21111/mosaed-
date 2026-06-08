import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';

import '../../data/auth_repository.dart';
import '../../data/models/auth_session.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> sendOtp(String phoneNumber) async {
    emit(const AuthLoading());
    try {
      await _repository.sendOtp(phoneNumber);
      emit(OtpSent(phoneNumber: phoneNumber));
    } on ServerFailure catch (e) {
      emit(AuthFailure(e.errMessage));
    } catch (_) {
      emit(const AuthFailure('حدث خطأ غير متوقع'));
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await _repository.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      emit(AuthVerified(session: session));
    } on ServerFailure catch (e) {
      emit(AuthFailure(e.errMessage));
    } catch (_) {
      emit(const AuthFailure('حدث خطأ غير متوقع'));
    }
  }

  Future<void> register({
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    emit(const AuthLoading());
    try {
      await _repository.registerCustomer(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
      );
      await _repository.sendOtp(phoneNumber);
      emit(OtpSent(phoneNumber: phoneNumber));
    } on ServerFailure catch (e) {
      emit(AuthFailure(e.errMessage));
    } catch (_) {
      emit(const AuthFailure('حدث خطأ غير متوقع'));
    }
  }

  Future<void> loginWithBiometric() async {
    emit(const AuthLoading());
    try {
      final session = await _repository.loginWithBiometric();
      emit(AuthVerified(session: session));
    } on ServerFailure catch (e) {
      emit(AuthFailure(e.errMessage));
    } catch (_) {
      emit(const AuthFailure('حدث خطأ غير متوقع'));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _repository.logout();
      emit(const AuthLoggedOut());
    } on ServerFailure catch (e) {
      emit(AuthFailure(e.errMessage));
    } catch (_) {
      emit(const AuthFailure('حدث خطأ غير متوقع'));
    }
  }

  void reset() => emit(const AuthInitial());
}
