import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/locale_keys.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../data/models/chat_message.dart';
import 'chat_app_bar.dart';
import 'chat_input_bar.dart';
import 'chat_load_older_button.dart';
import 'chat_messages_body.dart';
import 'chat_order_summary_bar.dart';

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
    required this.title,
    required this.loading,
    required this.messages,
    required this.scrollController,
    required this.inputController,
    required this.enabled,
    required this.sending,
    required this.recording,
    required this.recordDuration,
    required this.onRetry,
    required this.onSend,
    required this.onAttach,
    required this.onMicTap,
    required this.onCancelRecord,
    required this.onSendRecord,
    required this.onViewDetails,
    required this.onLoadOlder,
    this.peerImage,
    this.requestTitle,
    this.price,
    this.error,
    this.hasMore = false,
    this.loadingOlder = false,
  });

  final String title;
  final String? peerImage;
  final String? requestTitle;
  final double? price;
  final bool loading;
  final String? error;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final bool enabled;
  final bool sending;
  final bool recording;
  final Duration recordDuration;
  final bool hasMore;
  final bool loadingOlder;
  final VoidCallback onRetry;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onMicTap;
  final VoidCallback onCancelRecord;
  final VoidCallback onSendRecord;
  final VoidCallback onViewDetails;
  final VoidCallback onLoadOlder;

  @override
  Widget build(BuildContext context) {
    final orderTitle = requestTitle?.trim() ?? '';

    return Scaffold(
      backgroundColor: MosaedColors.background,
      appBar: ChatAppBar(title: title, peerImage: peerImage),
      body: Column(
        children: [
          if (orderTitle.isNotEmpty)
            ChatOrderSummaryBar(
              title: orderTitle,
              price: price,
              onViewDetails: onViewDetails,
            ),
          if (hasMore)
            ChatLoadOlderButton(
              loading: loadingOlder,
              onPressed: onLoadOlder,
            ),
          Expanded(
            child: ChatMessagesBody(
              loading: loading,
              error: error,
              messages: messages,
              scrollController: scrollController,
              peerName: title,
              peerImage: peerImage,
              onRetry: onRetry,
            ),
          ),
          ChatInputBar(
            controller: inputController,
            enabled: enabled,
            sending: sending,
            recording: recording,
            recordDuration: recordDuration,
            onSend: onSend,
            onAttach: onAttach,
            onMicTap: onMicTap,
            onCancelRecord: onCancelRecord,
            onSendRecord: onSendRecord,
          ),
        ],
      ),
    );
  }
}

String chatPeerTitle(String? peerName) {
  return peerName?.trim().isNotEmpty == true
      ? peerName!.trim()
      : LocaleKeys.mosaedWorkerPending.tr();
}
