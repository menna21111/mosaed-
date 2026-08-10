class PaymentRequest {
  const PaymentRequest({
    required this.id,
    required this.requestId,
    this.requestTitle,
    required this.amount,
    this.providerShare,
    this.platformShare,
    this.pointsUsed,
    this.pointsDiscountAmount,
    this.finalAmount,
    this.paymentMethod,
    required this.status,
    this.createdAt,
    this.paidAt,
  });

  final String id;
  final String requestId;
  final String? requestTitle;
  final double amount;
  final double? providerShare;
  final double? platformShare;
  final double? pointsUsed;
  final double? pointsDiscountAmount;
  final double? finalAmount;
  final String? paymentMethod;
  final String status;
  final String? createdAt;
  final String? paidAt;

  /// Amount the customer actually pays (after points discount when present).
  double get payableAmount => finalAmount ?? amount;

  bool get hasPointsApplied =>
      (pointsUsed ?? 0) > 0 || (pointsDiscountAmount ?? 0) > 0;

  bool get isAwaitingMethod {
    if (isPaid || isAwaitingCashConfirmation || isAwaitingOnlinePayment) {
      return false;
    }
    final s = status.toLowerCase();
    return s.contains('awaiting_method') ||
        s == 'pending' ||
        s == 'awaiting' ||
        paymentMethod == null ||
        paymentMethod!.trim().isEmpty;
  }

  bool get isAwaitingCashConfirmation {
    final s = status.toLowerCase();
    return s.contains('awaiting_cash') || s.contains('cash_confirmation');
  }

  bool get isAwaitingOnlinePayment {
    final s = status.toLowerCase();
    return s.contains('awaiting_gateway') ||
        s.contains('awaiting_online') ||
        s.contains('gateway');
  }

  bool get isPaid {
    final s = status.toLowerCase();
    return s.contains('paid') ||
        s.contains('completed') ||
        s.contains('success') ||
        paidAt != null;
  }

  bool get isCash => paymentMethod?.toLowerCase() == 'cash';
  bool get isOnline => paymentMethod?.toLowerCase() == 'online';

  String get statusKey {
    if (isPaid) return 'mosaedPaymentStatusPaid';
    if (isAwaitingCashConfirmation) return 'mosaedPaymentStatusAwaitingCash';
    if (isAwaitingOnlinePayment) return 'mosaedPaymentStatusAwaitingOnline';
    if (isAwaitingMethod) return 'mosaedPaymentStatusSelectMethod';
    return 'mosaedPaymentStatusPending';
  }

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id']?.toString() ??
          json['payment_request_id']?.toString() ??
          '',
      requestId: json['request_id']?.toString() ??
          json['custom_request_id']?.toString() ??
          json['booking_id']?.toString() ??
          '',
      requestTitle: json['request_title']?.toString() ??
          json['service_title']?.toString() ??
          json['title']?.toString(),
      amount: _toDouble(json['amount'] ?? json['total'] ?? json['final_cost']),
      providerShare: _toDoubleOrNull(json['provider_share']),
      platformShare: _toDoubleOrNull(json['platform_share']),
      pointsUsed: _toDoubleOrNull(json['points_used']),
      pointsDiscountAmount: _toDoubleOrNull(json['points_discount_amount']),
      finalAmount: _toDoubleOrNull(json['final_amount']),
      paymentMethod: json['payment_method']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      paidAt: json['paid_at']?.toString(),
    );
  }

  static double _toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
