import '../data/models/chat_message.dart';

class ChatAttachmentLimits {
  static const imageMaxBytes = 10 * 1024 * 1024;
  static const voiceMaxBytes = 15 * 1024 * 1024;
  static const fileMaxBytes = 25 * 1024 * 1024;

  static int maxBytesFor(String messageType) {
    switch (messageType) {
      case ChatMessageType.image:
        return imageMaxBytes;
      case ChatMessageType.voice:
        return voiceMaxBytes;
      default:
        return fileMaxBytes;
    }
  }
}
