import '../data/models/chat_message.dart';
import 'chat_socket_parser.dart';

class ChatInboxResult {
  const ChatInboxResult({
    required this.messages,
    this.changed = false,
    this.shouldScroll = false,
    this.shouldMarkRead = false,
  });

  final List<ChatMessage> messages;
  final bool changed;
  final bool shouldScroll;
  final bool shouldMarkRead;
}

ChatInboxResult applyChatSocketPayload({
  required List<ChatMessage> messages,
  required Map<String, dynamic> payload,
}) {
  final data = payload['data'];
  final map = data is Map<String, dynamic> ? data : payload;
  final event =
      (payload['event'] ?? map['event'] ?? payload['type'] ?? map['type'])
          ?.toString()
          .toLowerCase();

  if (event == 'connection_established' ||
      event == 'connected' ||
      event == 'connection_ack') {
    return ChatInboxResult(messages: messages);
  }

  if (event == 'messages_read') {
    final ids = payload['message_ids'] ?? map['message_ids'];
    if (ids is! List) return ChatInboxResult(messages: messages);
    final idSet = ids.map((e) => e.toString()).toSet();
    return ChatInboxResult(
      messages: messages
          .map((m) => idSet.contains(m.id) ? m.copyWith(isRead: true) : m)
          .toList(),
      changed: true,
    );
  }

  final messagePayload = extractChatMessageMap(payload);
  if (messagePayload == null) return ChatInboxResult(messages: messages);

  final message = ChatMessage.fromJson(messagePayload);
  if (message.id.isEmpty &&
      !message.hasCaption &&
      (message.attachmentUrl == null || message.attachmentUrl!.isEmpty)) {
    return ChatInboxResult(messages: messages);
  }
  if (message.id.isNotEmpty && messages.any((m) => m.id == message.id)) {
    return ChatInboxResult(messages: messages);
  }

  final pendingIndex = messages.indexWhere(
    (m) =>
        m.isLocalPending &&
        m.isFromCustomer &&
        m.messageType == message.messageType &&
        ((message.hasCaption && m.message == message.message) ||
            (!message.hasCaption && m.messageType != ChatMessageType.text)),
  );

  if (pendingIndex >= 0 && message.isFromCustomer) {
    final updated = [...messages];
    updated[pendingIndex] = message;
    return ChatInboxResult(
      messages: updated,
      changed: true,
      shouldScroll: true,
    );
  }

  return ChatInboxResult(
    messages: [...messages, message],
    changed: true,
    shouldScroll: true,
    shouldMarkRead: !message.isFromCustomer,
  );
}
