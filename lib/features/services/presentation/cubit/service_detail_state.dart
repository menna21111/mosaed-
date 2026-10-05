part of 'service_detail_cubit.dart';

abstract class ServiceDetailState extends Equatable {
  const ServiceDetailState();

  @override
  List<Object?> get props => [];
}

class ServiceDetailInitial extends ServiceDetailState {
  const ServiceDetailInitial();
}

class ServiceDetailLoading extends ServiceDetailState {
  const ServiceDetailLoading();
}

class ServiceDetailLoaded extends ServiceDetailState {
  const ServiceDetailLoaded({
    required this.detail,
    required this.previousWorks,
    this.selectedAttributeId,
  });

  final ExistedServiceDetail detail;
  final List<ServicePreviousWork> previousWorks;
  final String? selectedAttributeId;

  ServiceDetailLoaded copyWith({
    ExistedServiceDetail? detail,
    List<ServicePreviousWork>? previousWorks,
    String? selectedAttributeId,
  }) {
    return ServiceDetailLoaded(
      detail: detail ?? this.detail,
      previousWorks: previousWorks ?? this.previousWorks,
      selectedAttributeId: selectedAttributeId ?? this.selectedAttributeId,
    );
  }

  @override
  List<Object?> get props => [detail, previousWorks, selectedAttributeId];
}

class ServiceDetailFailure extends ServiceDetailState {
  const ServiceDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
