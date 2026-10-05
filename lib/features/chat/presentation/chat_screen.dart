import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../custom_service/presentation/custom_request_detail_screen.dart';
import '../data/chat_repository.dart';
import '../data/models/chat_message.dart';
import 'cubit/chat_cubit.dart';
import 'widgets/chat_attach_sheet.dart';
import 'widgets/chat_view.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.requestId,
    this.requestTitle,
    this.peerName,
    this.peerImage,
    this.price,
    this.isPreview = false,
  });

  final String requestId;
  final String? requestTitle;
  final String? peerName;
  final String? peerImage;
  final double? price;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        repository: context.read<ChatRepository>(),
        requestId: requestId,
        isPreview: isPreview,
      )..start(),
      child: _ChatView(
        requestId: requestId,
        requestTitle: requestTitle,
        peerName: peerName,
        peerImage: peerImage,
        price: price,
        isPreview: isPreview,
      ),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({
    required this.requestId,
    this.requestTitle,
    this.peerName,
    this.peerImage,
    this.price,
    this.isPreview = false,
  });

  final String requestId;
  final String? requestTitle;
  final String? peerName;
  final String? peerImage;
  final double? price;
  final bool isPreview;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSideEffects(ChatState state) {
    if (state.toast != null) {
      AppFunctions.showsToast(state.toast!, MosaedColors.danger, context);
    }
    if (state.restoreDraft != null) {
      _controller.text = state.restoreDraft!;
    }
    if (state.fileTooLargeMb != null) {
      AppFunctions.showsToast(
        LocaleKeys.mosaedFileTooLarge.tr(args: ['${state.fileTooLargeMb}']),
        MosaedColors.danger,
        context,
      );
    }
    if (state.micDenied) {
      AppFunctions.showsToast(
        LocaleKeys.mosaedMicPermission.tr(),
        MosaedColors.danger,
        context,
      );
    }
    if (state.toast != null ||
        state.restoreDraft != null ||
        state.fileTooLargeMb != null ||
        state.micDenied) {
      context.read<ChatCubit>().consumeSideEffects();
    }
  }

  Future<void> _onAttach() async {
    final cubit = context.read<ChatCubit>();
    final state = cubit.state;
    if (!state.enabled || state.recording) return;
    await showChatAttachSheet(
      context: context,
      onCamera: () => _pickImage(ImageSource.camera),
      onGallery: () => _pickImage(ImageSource.gallery),
      onFile: _pickFile,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null || !mounted) return;
      await context.read<ChatCubit>().sendAttachment(
            type: ChatMessageType.image,
            path: file.path,
            name: file.name,
          );
    } catch (_) {}
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      final file = result?.files.single;
      final path = file?.path;
      if (path == null || path.isEmpty || !mounted) return;
      await context.read<ChatCubit>().sendAttachment(
            type: ChatMessageType.file,
            path: path,
            name: file?.name,
          );
    } catch (_) {}
  }

  void _openRequestDetails() {
    if (widget.isPreview) return;
    AppFunctions.navigateTo(
      context,
      CustomRequestDetailScreen(requestId: widget.requestId),
      PageTransitionType.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.scrollNonce != current.scrollNonce ||
          previous.toast != current.toast ||
          previous.restoreDraft != current.restoreDraft ||
          previous.fileTooLargeMb != current.fileTooLargeMb ||
          previous.micDenied != current.micDenied,
      listener: (context, state) {
        if (state.scrollNonce != 0) _scrollToBottom();
        _onSideEffects(state);
      },
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        return ChatView(
          title: chatPeerTitle(widget.peerName),
          peerImage: widget.peerImage,
          requestTitle: widget.requestTitle,
          price: widget.price,
          loading: state.loading,
          error: state.error,
          messages: state.messages,
          scrollController: _scrollController,
          inputController: _controller,
          enabled: state.enabled,
          sending: state.sending,
          recording: state.recording,
          recordDuration: state.recordDuration,
          hasMore: state.hasMore,
          loadingOlder: state.loadingOlder,
          onRetry: cubit.retry,
          onSend: () {
            final text = _controller.text;
            _controller.clear();
            cubit.sendText(text);
          },
          onAttach: _onAttach,
          onMicTap: cubit.toggleRecording,
          onCancelRecord: cubit.cancelRecording,
          onSendRecord: cubit.sendRecording,
          onViewDetails: _openRequestDetails,
          onLoadOlder: cubit.loadOlder,
        );
      },
    );
  }
}
