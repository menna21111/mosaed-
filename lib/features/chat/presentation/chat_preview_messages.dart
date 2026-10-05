import '../data/models/chat_message.dart';

List<ChatMessage> chatPreviewMessages() {
  final now = DateTime.now();
  return [
    ChatMessage(
      id: 'p1',
      senderType: 'provider',
      senderId: '1',
      message: 'السلام عليكم، أنا جاهز للخدمة',
      isRead: true,
      createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
    ),
    ChatMessage(
      id: 'p2',
      senderType: 'customer',
      senderId: '2',
      message: 'وعليكم السلام، متى تقدر توصل؟',
      isRead: true,
      createdAt: now.subtract(const Duration(minutes: 50)).toIso8601String(),
    ),
    ChatMessage(
      id: 'p3',
      senderType: 'provider',
      senderId: '1',
      message: 'تمام، أنا بوصل لغاية الساعة 2',
      isRead: true,
      createdAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
    ),
  ];
}
