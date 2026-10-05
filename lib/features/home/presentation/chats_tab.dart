import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app/functions.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/constants/styles_manager.dart';
import '../../../core/network/failure.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/data/models/chat_conversation.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../services/presentation/widgets/address_chrome.dart';

enum _ChatFilter { all, active, unread, completed }

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final _searchController = TextEditingController();

  List<ChatConversation> _conversations = [];
  _ChatFilter _filter = _ChatFilter.all;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String _query = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (more) {
      if (!_hasMore || _loadingMore || _loading) return;
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final page = await context.read<ChatRepository>().getConversations(
            limit: 20,
            offset: more ? _conversations.length : 0,
          );
      if (!mounted) return;
      setState(() {
        _conversations =
            more ? [..._conversations, ...page.results] : page.results;
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } on ServerFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (!more) _conversations = [];
        _error = e.errMessage;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  List<ChatConversation> get _filtered {
    var list = _conversations;
    switch (_filter) {
      case _ChatFilter.active:
        list = list
            .where((c) => c.status == ChatConversationStatus.active)
            .toList();
        break;
      case _ChatFilter.unread:
        list = list.where((c) => c.hasUnread).toList();
        break;
      case _ChatFilter.completed:
        list = list
            .where((c) => c.status == ChatConversationStatus.completed)
            .toList();
        break;
      case _ChatFilter.all:
        break;
    }
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where((c) {
      return c.peerName.toLowerCase().contains(q) ||
          c.requestTitle.toLowerCase().contains(q) ||
          (c.lastMessage?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _openChat(ChatConversation conversation) async {
    final peerName = conversation.displayPeerName.isNotEmpty
        ? conversation.displayPeerName
        : LocaleKeys.mosaedWorkerPending.tr();
    await AppFunctions.navigateTo(
      context,
      ChatScreen(
        requestId: conversation.requestId,
        requestTitle: conversation.requestTitle.isNotEmpty
            ? conversation.requestTitle
            : null,
        peerName: peerName,
        peerImage: conversation.hasPeerImage ? conversation.peerImage : null,
        price: conversation.price,
        isPreview: conversation.isPreview,
      ),
      PageTransitionType.rightToLeft,
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final showSearchEmpty = _query.isNotEmpty && filtered.isEmpty && !_loading;
    final showEmpty = _query.isEmpty &&
        _conversations.isEmpty &&
        !_loading &&
        _error == null;
    final showError = _error != null && _conversations.isEmpty && !_loading;

    return ColoredBox(
      color: MosaedColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MosaedPageTitle(
              LocaleKeys.mosaedMyChats.tr(),
              showDivider: true,
            ),
            Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: _ChatSearchBar(
              controller: _searchController,
              query: _query,
              onClear: () => _searchController.clear(),
            ),
          ),
            SizedBox(height: 12.h),
            _ChatFilterBar(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: MosaedColors.brand,
                      ),
                    )
                  : showError
                      ? _ChatErrorState(
                          error: _error!,
                          onRetry: _load,
                        )
                      : showSearchEmpty
                          ? const _ChatEmptyIllustration(
                              image: ImageAssets.chatsSearchEmpty,
                              titleKey: LocaleKeys.mosaedNoSearchResults,
                              bodyKey: LocaleKeys.mosaedNoSearchResultsHint,
                            )
                          : showEmpty
                              ? _ChatEmptyState(onRefresh: _load)
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n.metrics.extentAfter < 240) {
                                      _load(more: true);
                                    }
                                    return false;
                                  },
                                  child: RefreshIndicator(
                                    onRefresh: _load,
                                    color: MosaedColors.brand,
                                    child: ListView.separated(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        16.w,
                                        8.h,
                                        16.w,
                                        24.h,
                                      ),
                                      itemCount: filtered.length +
                                          (_loadingMore ? 1 : 0),
                                      separatorBuilder: (_, _) => Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: MosaedColors.fieldBorder,
                                      ),
                                      itemBuilder: (_, i) {
                                        if (i >= filtered.length) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: MosaedColors.brand,
                                              ),
                                            ),
                                          );
                                        }
                                        return _ChatListTile(
                                          conversation: filtered[i],
                                          onTap: () => _openChat(filtered[i]),
                                        );
                                      },
                                    ),
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatSearchBar extends StatelessWidget {
  const _ChatSearchBar({
    required this.controller,
    required this.query,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    final side = const BorderSide(color: MosaedColors.fieldBorder);
    return SizedBox(
      height: 48.h,
      child: TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        style: getRegularStyle(
          fontSize: 14.sp,
          color: MosaedColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: MosaedColors.surfaceWhite,
          hintText: LocaleKeys.mosaedSearchChatsHint.tr(),
          hintStyle: getRegularStyle(
            fontSize: 14.sp,
            color: MosaedColors.textHint,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: MosaedColors.textHint,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: MosaedColors.textHint,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(borderRadius: radius, borderSide: side),
          enabledBorder:
              OutlineInputBorder(borderRadius: radius, borderSide: side),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: MosaedColors.brand, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ChatFilterBar extends StatelessWidget {
  const _ChatFilterBar({
    required this.filter,
    required this.onChanged,
  });

  final _ChatFilter filter;
  final ValueChanged<_ChatFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _FilterChip(
            label: LocaleKeys.mosaedChatsAll.tr(),
            selected: filter == _ChatFilter.all,
            onTap: () => onChanged(_ChatFilter.all),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: LocaleKeys.mosaedChatsActive.tr(),
            selected: filter == _ChatFilter.active,
            onTap: () => onChanged(_ChatFilter.active),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: LocaleKeys.mosaedChatsUnread.tr(),
            selected: filter == _ChatFilter.unread,
            onTap: () => onChanged(_ChatFilter.unread),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: LocaleKeys.mosaedChatsCompleted.tr(),
            selected: filter == _ChatFilter.completed,
            onTap: () => onChanged(_ChatFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MosaedColors.surfaceWhite,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? MosaedColors.brand : MosaedColors.fieldBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: (selected ? getSemiBoldStyle : getMediumStyle)(
              fontSize: selected ? 14.sp : 12.sp,
              color: selected ? MosaedColors.brand : MosaedColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.conversation,
    required this.onTap,
  });

  final ChatConversation conversation;
  final VoidCallback onTap;

  String _timeLabel(BuildContext context) {
    final dt = conversation.lastMessageAt;
    if (dt == null) return '';
    final local = dt.toLocal();
    if (context.locale.languageCode == 'ar') {
      final hour = local.hour;
      final isPm = hour >= 12;
      final h = hour % 12 == 0 ? 12 : hour % 12;
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m ${isPm ? 'م' : 'ص'}';
    }
    return DateFormat('h:mm a').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final preview = conversation.lastMessage?.trim().isNotEmpty == true
        ? conversation.lastMessage!
        : conversation.requestTitle.isNotEmpty
            ? conversation.requestTitle
            : LocaleKeys.mosaedTapToOpenChat.tr();
    final time = _timeLabel(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            _ChatAvatar(
              url: conversation.hasPeerImage ? conversation.peerImage : null,
              name: conversation.displayPeerName.isNotEmpty
                  ? conversation.displayPeerName
                  : LocaleKeys.mosaedWorkerPending.tr(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.displayPeerName.isNotEmpty
                        ? conversation.displayPeerName
                        : LocaleKeys.mosaedWorkerPending.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getBoldStyle(
                      fontSize: 15.sp,
                      color: MosaedColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      fontSize: 13.sp,
                      color: MosaedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: getRegularStyle(
                      fontSize: 12.sp,
                      color: MosaedColors.textHint,
                    ),
                  ),
                if (conversation.hasUnread) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: MosaedColors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 52.w,
        height: 52.w,
        color: MosaedColors.otpFill,
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initials(),
              )
            : _initials(),
      ),
    );
  }

  Widget _initials() {
    final trimmed = name.trim();
    final lower = trimmed.toLowerCase();
    final isGeneric = trimmed.isEmpty ||
        lower == 'provider' ||
        lower == 'worker' ||
        lower == 'technician' ||
        trimmed == 'فني' ||
        trimmed == 'عامل' ||
        trimmed == 'قيد التعيين';
    final initial = isGeneric ? 'ف' : trimmed[0].toUpperCase();
    return Center(
      child: Text(
        initial,
        style: getBoldStyle(fontSize: 18.sp, color: MosaedColors.brand),
      ),
    );
  }
}

class _ChatErrorState extends StatelessWidget {
  const _ChatErrorState({required this.error, required this.onRetry});

  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      color: MosaedColors.brand,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          Icon(
            Icons.wifi_off_rounded,
            size: 48.sp,
            color: MosaedColors.textHint,
          ),
          SizedBox(height: 16.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: 14.sp,
              color: MosaedColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('mosaedRetry'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MosaedColors.brand,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: const _ChatEmptyIllustration(
                  image: ImageAssets.chatsEmpty,
                  titleKey: LocaleKeys.mosaedNoChatsYetTitle,
                  bodyKey: LocaleKeys.mosaedNoChatsYetBody,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatEmptyIllustration extends StatelessWidget {
  const _ChatEmptyIllustration({
    required this.image,
    required this.titleKey,
    required this.bodyKey,
  });

  final String image;
  final String titleKey;
  final String bodyKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              width: 220.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(
              titleKey.tr(),
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: 17.sp,
                color: MosaedColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              bodyKey.tr(),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: 13.sp,
                color: MosaedColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
