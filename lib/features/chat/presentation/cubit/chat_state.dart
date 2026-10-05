part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.loading = true,
    this.sending = false,
    this.loadingOlder = false,
    this.hasMore = false,
    this.recording = false,
    this.recordDuration = Duration.zero,
    this.error,
    this.toast,
    this.restoreDraft,
    this.fileTooLargeMb,
    this.micDenied = false,
    this.scrollNonce = 0,
  });

  final List<ChatMessage> messages;
  final bool loading;
  final bool sending;
  final bool loadingOlder;
  final bool hasMore;
  final bool recording;
  final Duration recordDuration;
  final String? error;
  final String? toast;
  final String? restoreDraft;
  final int? fileTooLargeMb;
  final bool micDenied;
  final int scrollNonce;

  bool get enabled => !loading;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    bool? sending,
    bool? loadingOlder,
    bool? hasMore,
    bool? recording,
    Duration? recordDuration,
    String? error,
    bool clearError = false,
    String? toast,
    bool clearToast = false,
    String? restoreDraft,
    bool clearRestoreDraft = false,
    int? fileTooLargeMb,
    bool clearFileTooLarge = false,
    bool? micDenied,
    bool clearMicDenied = false,
    int? scrollNonce,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      loadingOlder: loadingOlder ?? this.loadingOlder,
      hasMore: hasMore ?? this.hasMore,
      recording: recording ?? this.recording,
      recordDuration: recordDuration ?? this.recordDuration,
      error: clearError ? null : (error ?? this.error),
      toast: clearToast ? null : (toast ?? this.toast),
      restoreDraft: clearRestoreDraft ? null : (restoreDraft ?? this.restoreDraft),
      fileTooLargeMb:
          clearFileTooLarge ? null : (fileTooLargeMb ?? this.fileTooLargeMb),
      micDenied: clearMicDenied ? false : (micDenied ?? this.micDenied),
      scrollNonce: scrollNonce ?? this.scrollNonce,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        loading,
        sending,
        loadingOlder,
        hasMore,
        recording,
        recordDuration,
        error,
        toast,
        restoreDraft,
        fileTooLargeMb,
        micDenied,
        scrollNonce,
      ];
}
