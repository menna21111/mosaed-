part of 'payment_cubit.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentSelecting extends PaymentState {
  const PaymentSelecting();
}

class PaymentResolving extends PaymentState {
  const PaymentResolving();
}

class PaymentPointsBusy extends PaymentState {
  const PaymentPointsBusy();
}

class PaymentMethodSelected extends PaymentState {
  const PaymentMethodSelected({
    required this.payment,
    required this.method,
  });

  final PaymentRequest payment;
  final String method;

  bool get isOnline => method == 'online';
  bool get isCash => method == 'cash';

  @override
  List<Object?> get props => [payment.id, method, payment.status];
}

class PaymentFailure extends PaymentState {
  const PaymentFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
