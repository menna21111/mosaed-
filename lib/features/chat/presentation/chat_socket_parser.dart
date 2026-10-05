Map<String, dynamic>? extractChatMessageMap(Map<String, dynamic> payload) {
  bool looksLikeMessage(Map<String, dynamic> map) {
    return map['id'] != null ||
        map['sender_type'] != null ||
        map['message_type'] != null ||
        map['attachment_url'] != null ||
        map['message'] is String;
  }

  final data = payload['data'];
  if (data is Map<String, dynamic>) {
    if (looksLikeMessage(data)) return data;
    final nested = data['message'];
    if (nested is Map<String, dynamic> && looksLikeMessage(nested)) {
      return nested;
    }
  }
  final message = payload['message'];
  if (message is Map<String, dynamic> && looksLikeMessage(message)) {
    return message;
  }
  if (looksLikeMessage(payload)) return payload;
  return null;
}
