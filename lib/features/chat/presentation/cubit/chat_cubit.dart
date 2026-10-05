import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/realtime/chat_session_registry.dart';
import '../../../../core/realtime/chat_socket_service.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_message.dart';
import '../chat_attachment_limits.dart';
import '../chat_local_message.dart';
import '../chat_preview_messages.dart';
import '../chat_socket_inbox.dart';
import '../chat_voice_recorder.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository repository,
    required this.requestId,
    this.isPreview = false,
  })  : _repository = repository,
        super(const ChatState()) {
    _voice.onTick = (duration) {
      if (!isClosed) emit(state.copyWith(recordDuration: duration));
    };
  }

  final ChatRepository _repository;
  final String requestId;
  final bool isPreview;

  final _voice = ChatVoiceRecorder();
  ChatSocketService? _socket;

  Future<void> start() async {
    if (isPreview) {
      emit(state.copyWith(messages: chatPreviewMessages(), loading: false));
      return;
    }
    ChatSessionRegistry.open(requestId);
    await Future.wait([loadHistory(), _connectSocket()]);
  }

  Future<void> retry() => start();

  Future<void> loadOlder() => loadHistory(loadOlder: true);

  Future<void> loadHistory({bool loadOlder = false}) async {
    if (isPreview) return;
    if (loadOlder && (!state.hasMore || state.loadingOlder)) return;

    emit(
      loadOlder
          ? state.copyWith(loadingOlder: true)
          : state.copyWith(loading: true, clearError: true),
    );

    try {
      final page = await _repository.getMessages(
        requestId: requestId,
        offset: loadOlder ? state.messages.length : 0,
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          messages: loadOlder
              ? [...page.results, ...state.messages]
              : page.results,
          hasMore: page.hasMore,
          loading: false,
          loadingOlder: false,
          clearError: true,
          scrollNonce: loadOlder ? state.scrollNonce : state.scrollNonce + 1,
        ),
      );

      if (!loadOlder) {
        await _repository.markMessagesAsRead(requestId);
      }
    } on ServerFailure catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          error: e.errMessage,
          loading: false,
          loadingOlder: false,
        ),
      );
    }
  }

  Future<void> sendText(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.sending || state.recording) return;

    if (isPreview) {
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            chatLocalMessage(type: ChatMessageType.text, text: text),
          ],
          scrollNonce: state.scrollNonce + 1,
        ),
      );
      return;
    }

    emit(state.copyWith(sending: true));
    try {
      if (_socket?.isConnected != true) {
        await _socket?.connect();
      }

      if (_socket?.isConnected == true && _socket!.sendMessage(text)) {
        if (isClosed) return;
        emit(
          state.copyWith(
            sending: false,
            messages: [
              ...state.messages,
              chatLocalMessage(type: ChatMessageType.text, text: text),
            ],
            clearError: true,
            scrollNonce: state.scrollNonce + 1,
          ),
        );
        return;
      }

      final message = await _repository.sendMessage(
        requestId: requestId,
        message: text,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          sending: false,
          messages: [...state.messages, message],
          clearError: true,
          scrollNonce: state.scrollNonce + 1,
        ),
      );
    } on ServerFailure catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sending: false,
          toast: e.errMessage,
          restoreDraft: text,
        ),
      );
    }
  }

  Future<void> sendAttachment({
    required String type,
    required String path,
    String? name,
    String? caption,
    int? duration,
  }) async {
    if (state.sending) return;
    final file = File(path);
    if (!file.existsSync()) return;

    final size = await file.length();
    final max = ChatAttachmentLimits.maxBytesFor(type);
    if (size > max) {
      final mb = (max / (1024 * 1024)).round();
      emit(state.copyWith(fileTooLargeMb: mb));
      return;
    }

    final local = chatLocalMessage(
      type: type,
      text: caption ?? '',
      attachmentUrl: path,
      duration: duration,
      fileName: name,
      fileSize: size,
    );

    if (isPreview) {
      emit(
        state.copyWith(
          messages: [...state.messages, local],
          scrollNonce: state.scrollNonce + 1,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sending: true,
        messages: [...state.messages, local],
        scrollNonce: state.scrollNonce + 1,
      ),
    );

    try {
      final sent = await _repository.send(
        requestId: requestId,
        messageType: type,
        message: caption,
        attachmentPath: path,
        attachmentName: name,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          sending: false,
          messages: state.messages
              .map((m) => m.id == local.id ? sent : m)
              .toList(),
          clearError: true,
        ),
      );
    } on ServerFailure catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sending: false,
          messages: state.messages.where((m) => m.id != local.id).toList(),
          toast: e.errMessage,
        ),
      );
    }
  }

  Future<void> toggleRecording() async {
    if (state.recording) {
      await sendRecording();
      return;
    }

    final allowed = await _voice.hasPermission();
    if (!allowed) {
      emit(state.copyWith(micDenied: true));
      return;
    }

    try {
      await _voice.start();
    } catch (_) {
      if (!isClosed) emit(state.copyWith(micDenied: true));
      return;
    }
    if (isClosed) return;
    emit(
      state.copyWith(
        recording: true,
        recordDuration: Duration.zero,
      ),
    );
  }

  Future<void> cancelRecording() async {
    await _voice.cancel();
    if (isClosed) return;
    emit(
      state.copyWith(
        recording: false,
        recordDuration: Duration.zero,
      ),
    );
  }

  Future<void> sendRecording() async {
    final take = await _voice.stop();
    if (isClosed) return;
    emit(
      state.copyWith(
        recording: false,
        recordDuration: Duration.zero,
      ),
    );
    if (take == null) return;
    await sendAttachment(
      type: ChatMessageType.voice,
      path: take.path,
      name: 'voice_note.m4a',
      duration: take.seconds,
    );
  }

  void consumeSideEffects() {
    if (state.toast == null &&
        state.restoreDraft == null &&
        state.fileTooLargeMb == null &&
        !state.micDenied) {
      return;
    }
    emit(
      state.copyWith(
        clearToast: true,
        clearRestoreDraft: true,
        clearFileTooLarge: true,
        clearMicDenied: true,
      ),
    );
  }

  Future<void> _connectSocket() async {
    if (isPreview) return;
    await _socket?.disconnect();
    _socket = ChatSocketService(
      requestId: requestId,
      onMessage: _onSocketMessage,
      onConnected: (_) {},
      onClose: (_, _) {},
    );
    await _socket!.connect();
  }

  void _onSocketMessage(Map<String, dynamic> payload) {
    if (isClosed) return;
    final result = applyChatSocketPayload(
      messages: state.messages,
      payload: payload,
    );
    if (!result.changed) return;
    emit(
      state.copyWith(
        messages: result.messages,
        scrollNonce: result.shouldScroll
            ? state.scrollNonce + 1
            : state.scrollNonce,
      ),
    );
    if (result.shouldMarkRead) {
      _repository.markMessagesAsRead(requestId);
    }
  }

  @override
  Future<void> close() async {
    if (!isPreview) {
      ChatSessionRegistry.close(requestId);
      await _socket?.disconnect();
    }
    await _voice.dispose();
    return super.close();
  }
}
