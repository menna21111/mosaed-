import 'package:easy_localization/easy_localization.dart';

/// Completion form for booking / custom-request detail.
///
/// Example (booking):
/// ```json
/// {
///   "id": "...",
///   "booking_id": "...",
///   "notes": "",
///   "status": "provider_arrived",
///   "started_at": "2026-07-27T07:38:56.252595Z",
///   "is_finished": false,
///   "finished_at": null,
///   "media": [],
///   "previous_work": null,
///   "payment_request_id": null,
///   "payment_status": null,
///   "created_at": "...",
///   "updated_at": "..."
/// }
/// ```
class CompletionForm {
  const CompletionForm({
    required this.id,
    required this.workId,
    required this.status,
    required this.isFinished,
    this.startedAt,
    this.finishedAt,
    this.notes,
    this.beforeImage,
    this.afterImage,
    this.createdAt,
    this.updatedAt,
    this.paymentRequestId,
    this.paymentStatus,
    this.toolsUsed = const [],
    this.materialsUsed = const [],
    this.raw = const {},
  });

  final String id;

  /// booking_id أو request_id حسب النوع.
  final String workId;
  final String status;
  final bool isFinished;
  final String? startedAt;
  final String? finishedAt;
  final String? notes;
  final String? beforeImage;
  final String? afterImage;
  final String? createdAt;
  final String? updatedAt;
  final String? paymentRequestId;
  final String? paymentStatus;
  final List<String> toolsUsed;
  final List<String> materialsUsed;
  final Map<String, dynamic> raw;

  bool get hasStarted => _hasText(startedAt);

  bool get hasFinished =>
      isFinished || _hasText(finishedAt);

  /// لو `started_at` null → يظهر زر تأكيد وصول الفني.
  bool get needsArrivalConfirm => !hasFinished && !hasStarted;

  bool get isProviderArrived {
    if (hasFinished) return false;
    final s = status.toLowerCase().trim();
    return s == 'provider_arrived' ||
        s.contains('arrived') ||
        hasStarted;
  }

  bool get hasPaymentRequest => _hasText(paymentRequestId);

  /// الدفع يظهر فقط بعد ما الشغل يخلص (`is_finished` / `finished_at`).
  bool get canShowPayment => hasFinished;

  /// خلصان بس لسه مفيش payment_request — بنورّي رسالة انتظار.
  bool get isAwaitingPaymentCreation =>
      hasFinished && !hasPaymentRequest && !_hasText(paymentStatus);

  String get _paymentStatusLower =>
      (paymentStatus ?? '').toLowerCase().trim();

  /// اختار أونلاين بالفعل → افتح WebView، من غير select-method تاني.
  bool get isAwaitingGatewayPayment {
    final s = _paymentStatusLower;
    return s.contains('awaiting_gateway') ||
        s.contains('awaiting_online') ||
        s.contains('gateway');
  }

  bool get isAwaitingCashPayment {
    final s = _paymentStatusLower;
    return s.contains('awaiting_cash') || s.contains('cash_confirmation');
  }

  bool get isPaymentPaid {
    final s = _paymentStatusLower;
    return s.contains('paid') ||
        s.contains('completed') ||
        s.contains('success');
  }

  /// لسه مختارش طريقة (null أو awaiting_method).
  bool get needsPaymentMethodChoice =>
      hasFinished &&
      !isPaymentPaid &&
      !isAwaitingGatewayPayment &&
      !isAwaitingCashPayment;

  bool get isWaiting {
    final s = status.toLowerCase().trim();
    return s == 'waiting' || s.isEmpty;
  }

  bool get hasBeforeImage => _hasText(beforeImage);

  bool get hasAfterImage => _hasText(afterImage);

  String get statusLabelKey {
    if (hasFinished) return 'mosaedCompletionStatusFinished';
    if (isProviderArrived) return 'mosaedCompletionStatusArrived';
    if (isWaiting) return 'mosaedCompletionStatusWaiting';
    return 'mosaedCompletionStatusInProgress';
  }

  String? get startedAtFormatted =>
      startedAt == null ? null : formatDateTime(startedAt!);

  String? get finishedAtFormatted =>
      finishedAt == null ? null : formatDateTime(finishedAt!);

  factory CompletionForm.fromJson(Map<String, dynamic> json) {
    final previousWork = json['previous_work'];
    final previousMap = previousWork is Map
        ? Map<String, dynamic>.from(previousWork)
        : null;

    final media = json['media'];
    String? before;
    String? after;
    if (media is List) {
      for (final item in media) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final type =
            (map['type'] ?? map['kind'] ?? '').toString().toLowerCase();
        final url = map['url']?.toString() ??
            map['image']?.toString() ??
            map['file']?.toString() ??
            '';
        if (url.isEmpty) continue;
        if (type.contains('before') || type.contains('قبل')) {
          before ??= url;
        } else if (type.contains('after') || type.contains('بعد')) {
          after ??= url;
        } else {
          before ??= url;
          if (before != url) after ??= url;
        }
      }
    }

    // previous_work هو المصدر الأساسي لصور قبل/بعد في booking completion.
    before = _nullableUrl(
          previousMap?['before_image'] ??
              before ??
              json['before_image'],
        );
    after = _nullableUrl(
          previousMap?['after_image'] ??
              after ??
              json['after_image'],
        );

    final workId = json['booking_id']?.toString() ??
        json['request_id']?.toString() ??
        json['custom_request_id']?.toString() ??
        json['id']?.toString() ??
        '';

    final notesRaw = json['notes']?.toString();
    final notes = (notesRaw == null || notesRaw.trim().isEmpty)
        ? null
        : notesRaw.trim();

    return CompletionForm(
      id: json['id']?.toString() ?? workId,
      workId: workId,
      status: json['status']?.toString() ?? '',
      isFinished: json['is_finished'] == true,
      startedAt: _nullableText(json['started_at']?.toString()),
      finishedAt: _nullableText(json['finished_at']?.toString()),
      notes: notes,
      beforeImage: before,
      afterImage: after,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      paymentRequestId: _nullableText(json['payment_request_id']?.toString()),
      paymentStatus: _nullableText(json['payment_status']?.toString()),
      toolsUsed: _stringList(json['tools_used'] ?? json['tools']),
      materialsUsed: _stringList(json['materials_used'] ?? json['materials']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  CompletionForm copyWith({
    String? startedAt,
    bool? isFinished,
    String? finishedAt,
    String? status,
    String? notes,
    String? paymentRequestId,
    String? paymentStatus,
  }) {
    return CompletionForm(
      id: id,
      workId: workId,
      status: status ?? this.status,
      isFinished: isFinished ?? this.isFinished,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      notes: notes ?? this.notes,
      beforeImage: beforeImage,
      afterImage: afterImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      paymentRequestId: paymentRequestId ?? this.paymentRequestId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      toolsUsed: toolsUsed,
      materialsUsed: materialsUsed,
      raw: raw,
    );
  }

  static String formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('yyyy-MM-dd • HH:mm').format(dt.toLocal());
    } catch (_) {
      return raw;
    }
  }

  static bool _hasText(String? value) {
    if (value == null) return false;
    final text = value.trim();
    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  static String? _nullableText(String? value) {
    if (!_hasText(value)) return null;
    return value!.trim();
  }

  static String? _nullableUrl(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}
