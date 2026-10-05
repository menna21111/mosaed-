import '../data/models/chat_message.dart';

ChatMessage chatLocalMessage({
  required String type,
  String text = '',
  String? attachmentUrl,
  int? duration,
  String? fileName,
  int? fileSize,
}) {
  return ChatMessage(
    id: 'local_${DateTime.now().millisecondsSinceEpoch}',
    senderType: 'customer',
    senderId: '',
    message: text,
    isRead: false,
    createdAt: DateTime.now().toIso8601String(),
    messageType: type,
    attachmentUrl: attachmentUrl,
    attachmentDuration: duration,
    fileName: fileName,
    fileSize: fileSize,
  );
}
