import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';
import '../../../app/app.dart';
import '../../../app/functions.dart';
import '../../../core/constants/mosaed_colors.dart';
import '../../../core/realtime/chat_session_registry.dart';
import '../../../features/notifications/data/notifications_repository.dart';
import '../../../features/notifications/presentation/notifications_screen.dart';
import '../firebase_options.dart';
import 'notification_manager.dart';






const _channelId = 'mosaed_customer_channel';
const _channelName = 'Mosaed Notifications';
const _channelDescription = 'Notifications for the Mosaed customer app';

/// Top-level background handler (must not be a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint(
    'Background message: ${message.notification?.title} — '
    '${message.notification?.body}',
  );

  final backgroundPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await backgroundPlugin.initialize(initializationSettings);

  final notification = message.notification;
  final data = message.data;
  final title = notification?.title ?? data['title']?.toString();
  final body = notification?.body ?? data['body']?.toString();
  if (title == null && body == null) return;

  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  await backgroundPlugin.show(
    notification?.hashCode ?? Object.hash(title, body),
    title,
    body,
    notificationDetails,
    payload: data['route']?.toString() ?? '',
  );
}

/// FCM + local notifications (same wiring pattern as reefsaudi).
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationsRepository? _notificationsRepository;
  static void Function(Map<String, dynamic> data)? onForegroundPushData;

  static bool _firebaseReady = false;
  static bool _messagingReady = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static DateTime? _lastAlertAt;
  static String? _lastAlertKey;

  static void bindNotificationsRepository(NotificationsRepository repository) {
    _notificationsRepository = repository;
  }

  static Future<String?> getToken() async {
    try {
      if (kIsWeb) return null;
      if (!_firebaseReady) return null;
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Fast Firebase bootstrap — await before [runApp].
  static Future<void> initializeFirebase() async {
    if (_firebaseReady) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _firebaseReady = true;
      debugPrint(
        'Firebase initialized (${Firebase.app().options.projectId})',
      );
    } catch (e, st) {
      // Already configured (e.g. via GoogleService-Info.plist) is OK.
      if (Firebase.apps.isNotEmpty) {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        _firebaseReady = true;
        debugPrint(
          'Firebase already configured (${Firebase.app().options.projectId})',
        );
        return;
      }
      debugPrint('Firebase init failed: $e');
      debugPrint('$st');
    }
  }

  /// Permissions + listeners + token. Prefer calling after [runApp].
  static Future<void> initializeMessaging() async {
    if (_messagingReady) return;
    if (!_firebaseReady) {
      await initializeFirebase();
      if (!_firebaseReady) return;
    }

    try {
      if (!await NotificationManager.isNotificationsEnabled()) {
        debugPrint('Push notifications disabled by user preference');
        return;
      }

      await _setupLocalNotifications();
      await _requestPermissions();
      _setupMessageHandlers();
      _messaging.onTokenRefresh.listen((_) => syncTokenWithBackend());
      unawaited(handleInitialMessage(
        await FirebaseMessaging.instance.getInitialMessage(),
      ));
      unawaited(syncTokenWithBackend());
      _messagingReady = true;
      debugPrint('Push messaging ready');
    } catch (e, st) {
      debugPrint('Push messaging init failed: $e');
      debugPrint('$st');
    }
  }

  /// Full init (Firebase + messaging).
  static Future<void> initialize() async {
    await initializeFirebase();
    await initializeMessaging();
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _navigateTo(payload);
        } else {
          _navigateToNotifications();
        }
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageNavigation);
  }

  static Future<void> handleInitialMessage(RemoteMessage? message) async {
    if (message == null) return;
    _handleRemoteMessageNavigation(message);
  }

  static Future<void> syncTokenWithBackend() async {
    if (_notificationsRepository == null) return;
    if (!await NotificationManager.isNotificationsEnabled()) return;

    final token = await getToken();
    if (token == null || token.isEmpty) {
      debugPrint('FCM token empty — skip backend register');
      return;
    }

    try {
      await _notificationsRepository!.registerDeviceToken(token);
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  static Future<void> removeTokenFromBackend() async {
    if (_notificationsRepository == null) return;

    final token = await getToken();
    if (token == null || token.isEmpty) return;

    try {
      await _notificationsRepository!.deleteDeviceToken(token);
    } catch (e) {
      debugPrint('Failed to delete FCM token: $e');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);

    if (data['event']?.toString() == 'new_chat_message') {
      final requestId = data['request_id']?.toString();
      if (requestId != null && ChatSessionRegistry.isOpen(requestId)) {
        return;
      }
    }

    onForegroundPushData?.call(data);
    unawaited(_showLocalNotification(message));

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? data['title']?.toString();
    final body = message.notification?.body ?? data['body']?.toString();
    final text = [title, body]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join('\n');
    if (text.isNotEmpty) {
      AppFunctions.showsToast(text, MosaedColors.primary, context);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    final title = notification?.title ?? data['title']?.toString();
    final body = notification?.body ?? data['body']?.toString();
    if (title == null && body == null) return;

    await showIncomingAlert(
      title: title,
      body: body,
      payload: data['route']?.toString() ?? '',
      id: notification?.hashCode ?? Object.hash(title, body),
    );
  }

  /// Sound + vibration for in-app WebSocket notifications.
  static Future<void> notifyFromSocket({
    String? title,
    String? body,
    String payload = '',
  }) async {
    try {
      await HapticFeedback.heavyImpact();
      await HapticFeedback.vibrate();
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    final hasText =
        (title != null && title.isNotEmpty) || (body != null && body.isNotEmpty);
    if (!hasText) return;
    if (!await NotificationManager.isNotificationsEnabled()) return;

    await showIncomingAlert(
      title: title,
      body: body,
      payload: payload,
    );
  }

  static Future<void> showIncomingAlert({
    String? title,
    String? body,
    String payload = '',
    int? id,
  }) async {
    if (title == null && body == null) return;

    final key = '${title ?? ''}|${body ?? ''}';
    final now = DateTime.now();
    if (_lastAlertKey == key &&
        _lastAlertAt != null &&
        now.difference(_lastAlertAt!) < const Duration(milliseconds: 1200)) {
      return;
    }
    _lastAlertKey = key;
    _lastAlertAt = now;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _localNotificationsPlugin.show(
        id ?? Object.hash(title, body, DateTime.now().millisecondsSinceEpoch),
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Local notification failed: $e');
    }
  }

  static void _handleRemoteMessageNavigation(RemoteMessage message) {
    final route = message.data['route']?.toString();
    if (route != null && route.isNotEmpty) {
      _navigateTo(route);
    } else {
      _navigateToNotifications();
    }
  }

  static void _navigateTo(String route) {
    navigatorKey.currentState?.pushNamed(route);
  }

  static void _navigateToNotifications() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    AppFunctions.navigateTo(
      context,
      const NotificationsScreen(),
      PageTransitionType.rightToLeft,
    );
  }
}
