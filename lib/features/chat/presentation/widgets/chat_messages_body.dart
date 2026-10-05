import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/constants/styles_manager.dart';
import '../../data/models/chat_message.dart';
import 'chat_error_state.dart';
import 'chat_message_bubble.dart';
import 'chat_today_chip.dart';

class ChatMessagesBody extends StatelessWidget {
  const ChatMessagesBody({
    super.key,
    required this.loading,
    required this.messages,
    required this.scrollController,
    required this.peerName,
    required this.onRetry,
    this.error,
    this.peerImage,
  });

  final bool loading;
  final String? error;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String peerName;
  final String? peerImage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: MosaedColors.brand),
      );
    }

    if (error != null && messages.isEmpty) {
      return ChatErrorState(error: error!, onRetry: onRetry);
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.mosaedWriteMessage.tr(),
          style: getRegularStyle(
            fontSize: 14.sp,
            color: MosaedColors.textHint,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const ChatTodayChip();
        return ChatMessageBubble(
          message: messages[index - 1],
          peerImage: peerImage,
          peerName: peerName,
        );
      },
    );
  }
}
