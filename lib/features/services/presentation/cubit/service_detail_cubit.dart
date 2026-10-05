import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../data/models/existed_service.dart';
import '../../data/services_repository.dart';

part 'service_detail_state.dart';

class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  ServiceDetailCubit(this._repository) : super(const ServiceDetailInitial());

  final ServicesRepository _repository;

  Future<void> load(String serviceId) async {
    emit(const ServiceDetailLoading());
    try {
      final bundle = await _repository.loadServiceDetail(serviceId);
      final defaultAttributeId = bundle.detail.attributes.isNotEmpty
          ? bundle.detail.attributes.first.id
          : null;
      emit(
        ServiceDetailLoaded(
          detail: bundle.detail,
          previousWorks: bundle.previousWorks,
          selectedAttributeId: defaultAttributeId,
        ),
      );
    } on ServerFailure catch (e) {
      emit(ServiceDetailFailure(e.errMessage));
    } catch (_) {
      emit(const ServiceDetailFailure('حدث خطأ غير متوقع'));
    }
  }

  void selectAttribute(String? value) {
    if (value == null) return;
    final current = state;
    if (current is ServiceDetailLoaded) {
      emit(current.copyWith(selectedAttributeId: value));
    }
  }
}
