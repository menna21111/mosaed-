class CustomerPointsWallet {
  const CustomerPointsWallet({
    required this.pointsBalance,
    required this.totalEarnedPoints,
    required this.totalRedeemedPoints,
    this.updatedAt,
    this.recentTransactions = const [],

  });

  final double pointsBalance;
  final double totalEarnedPoints;
  final double totalRedeemedPoints;
  final String? updatedAt;
  final List<PointsTransaction> recentTransactions;

  bool get hasPoints => pointsBalance > 0;

  /// Supports both flat payload and `{ "wallet": {...}, "recent_transactions": [] }`.
  factory CustomerPointsWallet.fromJson(Map<String, dynamic> json) {
    final walletRaw = json['wallet'];
    final Map<String, dynamic> wallet = walletRaw is Map
        ? Map<String, dynamic>.from(walletRaw)
        : json;

    final txRaw = json['recent_transactions'];
    final transactions = <PointsTransaction>[];
    if (txRaw is List) {
      for (final item in txRaw) {
        if (item is Map) {
          transactions.add(
            PointsTransaction.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return CustomerPointsWallet(
      pointsBalance: _toDouble(
        wallet['points_balance'] ?? wallet['balance'] ?? wallet['points'],
      ),
      totalEarnedPoints: _toDouble(
        wallet['total_earned_points'] ?? wallet['total_earned'],
      ),
      totalRedeemedPoints: _toDouble(
        wallet['total_redeemed_points'] ?? wallet['total_redeemed'],
      ),
      updatedAt: wallet['updated_at']?.toString(),
      recentTransactions: transactions,
    );
  }

  static double _toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
}

class PointsTransaction {
  const PointsTransaction({
    required this.id,
    required this.points,
    this.type,
    this.description,
    this.createdAt,
  });

  final String id;
  final double points;
  final String? type;
  final String? description;
  final String? createdAt;

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id']?.toString() ?? '',
      points: double.tryParse(
            (json['points'] ?? json['amount'] ?? 0).toString(),
          ) ??
          0,
      type: json['type']?.toString() ?? json['transaction_type']?.toString(),
      description: json['description']?.toString() ??
          json['note']?.toString() ??
          json['reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['date']?.toString(),
    );
  }
}
