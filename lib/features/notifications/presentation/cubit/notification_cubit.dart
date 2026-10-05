import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app.dart';
import '../../../../app/functions.dart';
import '../../../../core/constants/mosaed_colors.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/realtime/chat_session_registry.dart';
import '../../../../core/realtime/notification_socket_service.dart';
import '../../../../core/services/notification/push_notification_service.dart';
import '../../data/models/app_notification.dart';
import '../../data/notifications_repository.dart';

part 'notification_state.dart';

/// Events that should make the orders list refresh itself.
const _orderRefreshEvents = {
  'offer_received',
  'new_offer',
  'offer_accepted',
  'offer_rejected',
  'provider_arrived',
  'service_started',
  'service_completed',
  'work_finished',
  'booking_status_changed',
  'custom_request_status_changed',
  'payment_required',
  'payment_confirmed',
};

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(const NotificationState());

  final NotificationsRepository _repository;
  NotificationSocketService? _socket;

  /// Fired when an event arrives that invalidates the orders list.
  void Function()? onOrdersChanged;

  Future<void> startRealtime() async {
    await _socket?.disconnect();
    emit(state.copyWith(
      socketConnecting: true,
      socketConnected: false,
      socketError: null,
    ));

    _socket = NotificationSocketService(
      onMessage: _handleSocketMessage,
      onConnected: (_) {
        emit(state.copyWith(
          socketConnected: true,
          socketConnecting: false,
          socketError: null,
        ));
      },
      onClose: (code, reason) {
        emit(state.copyWith(
          socketConnected: false,
          socketConnecting: false,
          socketError: reason ?? (code != null ? 'code $code' : 'disconnected'),
        ));
      },
      onReconnect: syncAfterReconnect,
    );
    await _socket!.connect();

    if (!_socket!.isConnected) {
      emit(state.copyWith(
        socketConnected: false,
        socketConnecting: false,
        socketError: 'failed to connect',
      ));
    }

    await refreshUnreadCount();
  }

  Future<void> stopRealtime() async {
    await _socket?.disconnect();
    _socket = null;
    emit(state.copyWith(
      socketConnected: false,
      socketConnecting: false,
    ));
  }

  Future<void> syncAfterReconnect() async {
    await refreshUnreadCount();
    await loadNotifications(refresh: true);
  }

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {}
  }

  Future<void> loadNotifications({
    bool refresh = false,
    bool? isRead,
  }) async {
    if (state.loadingMore && !refresh) return;

    emit(state.copyWith(
      loading: refresh || state.notifications.isEmpty,
      loadingMore: !refresh && state.notifications.isNotEmpty,
      error: null,
    ));

    try {
      final offset = refresh ? 0 : state.notifications.length;
      final page = await _repository.getNotifications(
        isRead: isRead,
        offset: offset,
      );

      final merged =
          refresh ? page.results : [...state.notifications, ...page.results];

      emit(state.copyWith(
        notifications: merged,
        hasMore: page.hasMore,
        loading: false,
        loadingMore: false,
      ));
    } on ServerFailure catch (e) {
      emit(state.copyWith(
        loading: false,
        loadingMore: false,
        error: e.errMessage,
      ));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final updated = state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(state.copyWith(
        notifications: updated,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      ));
    } on ServerFailure catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      emit(state.copyWith(unreadCount: 0));
      await loadNotifications(refresh: true);
    } on ServerFailure catch (_) {}
  }

  void handlePushPayload(Map<String, dynamic> payload) {
    _handleSocketMessage(payload);
  }

  void _handleSocketMessage(Map<String, dynamic> payload) {
    final event = payload['event']?.toString() ?? '';

    if (event == 'new_chat_message') {
      final requestId = payload['request_id']?.toString();
      if (requestId != null && ChatSessionRegistry.isOpen(requestId)) {
        return;
      }
    }

    final notification = AppNotification.fromSocket(payload);
    if (notification.id.isNotEmpty || notification.title.isNotEmpty) {
      emit(state.copyWith(
        unreadCount: state.unreadCount + 1,
        notifications: [notification, ...state.notifications],
      ));
    } else {
      emit(state.copyWith(unreadCount: state.unreadCount + 1));
    }

    _showToast(payload);
    unawaited(
      PushNotificationService.notifyFromSocket(
        title: payload['title']?.toString(),
        body: payload['body']?.toString(),
        payload: payload['route']?.toString() ?? '',
      ),
    );

    if (_orderRefreshEvents.contains(event)) {
      onOrdersChanged?.call();
    }
  }

  void _showToast(Map<String, dynamic> payload) {
    final title = payload['title']?.toString();
    final body = payload['body']?.toString();
    final message = [title, body]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join('\n');
    if (message.isEmpty) return;

    // Defer until after the current frame so Overlay is available.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      AppFunctions.showsToast(message, MosaedColors.primary, context);
    });
  }

  @override
  Future<void> close() async {
    await stopRealtime();
    return super.close();
  }
}
