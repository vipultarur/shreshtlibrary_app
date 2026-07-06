import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../firebase_options.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── Background handler (top-level, @pragma required) ────────────────────────
// This runs in an ISOLATE when the app is terminated or in the background.
// FCM automatically shows the notification tray for messages that contain a
// `notification` payload.  For data-only messages we show one ourselves.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If the message has NO notification payload (data-only), show one manually.
  if (message.notification == null && message.data.isNotEmpty) {
    final plugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    await plugin.initialize(
        const InitializationSettings(android: androidSettings));

    final androidPlugin =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'admin_notifications',
        'Admin Notifications',
        description: 'Notifications from the admin',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    final title = message.data['title'] ?? 'Shresht Library';
    final body = message.data['body'] ?? '';
    final int id =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'admin_notifications',
          'Admin Notifications',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}

// ─── Global stream controllers ───────────────────────────────────────────────
final StreamController<String> _actionStreamController =
    StreamController<String>.broadcast();
final StreamController<RemoteMessage> _foregroundMessageController =
    StreamController<RemoteMessage>.broadcast();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId != null) {
    _actionStreamController.add(notificationResponse.actionId!);
  } else if (notificationResponse.payload != null) {
    _actionStreamController.add('payload:${notificationResponse.payload}');
  }
}

// ─── NotificationService ─────────────────────────────────────────────────────
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _sessionTimer;
  int _sessionSeconds = 0;

  Stream<String> get actionStream => _actionStreamController.stream;
  Stream<RemoteMessage> get foregroundMessageStream =>
      _foregroundMessageController.stream;

  // ── Notification channels ──────────────────────────────────────────────────
  static const AndroidNotificationChannel _adminChannel =
      AndroidNotificationChannel(
    'admin_notifications',
    'Admin Notifications',
    description: 'Notifications from the admin',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const AndroidNotificationChannel _sessionChannel =
      AndroidNotificationChannel(
    'session_notifications',
    'Study Session',
    description: 'Active study session notifications',
    importance: Importance.low,
  );

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'default_notifications',
    'General Notifications',
    description: 'General notifications like payments',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ── init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    try {
      // Firebase is already initialised in main.dart; catch duplicate-init
      try {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      } catch (_) {}

      // Register background handler FIRST
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // flutter_local_notifications initialisation
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');

      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: androidSettings),
        onDidReceiveNotificationResponse: (NotificationResponse r) {
          debugPrint('Notification tapped: ${r.payload}');
          if (r.actionId != null) {
            _actionStreamController.add(r.actionId!);
          } else if (r.payload != null) {
            _actionStreamController.add('payload:${r.payload}');
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Create channels
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_adminChannel);
        await androidPlugin.createNotificationChannel(_sessionChannel);
        await androidPlugin.createNotificationChannel(_defaultChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      // ── FCM permission ────────────────────────────────────────────────────
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // ── Foreground handler ────────────────────────────────────────────────
      // When app is open, FCM suppresses the system notification by default.
      // We re-show it ourselves using flutter_local_notifications.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message: ${message.messageId}');

        // 1. Broadcast for in-app real-time update
        _foregroundMessageController.add(message);

        // 2. Build title/body from notification payload OR data payload
        final String title = message.notification?.title ??
            message.data['title'] ??
            'Shresht Library';
        final String body =
            message.notification?.body ?? message.data['body'] ?? '';

        if (title.isNotEmpty || body.isNotEmpty) {
          _showAdminNotification(title: title, body: body);
        }
      });

      // ── Tap handlers ──────────────────────────────────────────────────────
      // App opened by tapping a notification while it was in the background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] onMessageOpenedApp: ${message.data}');
        _handleMessageTap(message);
      });

      // App launched from a terminated state by tapping a notification
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] getInitialMessage: ${initialMessage.data}');
        _handleMessageTap(initialMessage);
      }

      // ── FCM token ─────────────────────────────────────────────────────────
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] Token: $token');
    } catch (e, st) {
      debugPrint('[FCM] init error: $e\n$st');
    }
  }

  // ── Helper: show an admin-channel notification ────────────────────────────
  Future<void> _showAdminNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'admin_notifications',
          'Admin Notifications',
          channelDescription: 'Notifications from the admin',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_notification',
        ),
      ),
      payload: payload,
    );
  }

  // ── Public showNotification (used from other places) ──────────────────────
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_notifications',
    String channelName = 'General Notifications',
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_notification',
        ),
      ),
      payload: payload,
    );
  }

  // ── Handle message tap (navigate to correct screen) ───────────────────────
  void _handleMessageTap(RemoteMessage message) {
    final String? type = message.data['type'];
    if (type != null) {
      _actionStreamController.add('deeplink:$type');
    } else {
      _actionStreamController.add('payload:notifications');
    }
  }

  // ── Study Session notification ────────────────────────────────────────────
  Future<void> startStudySessionNotification() async {
    _sessionSeconds = 0;
    _updateSessionNotification();
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      if (_sessionSeconds % 60 == 0) {
        _updateSessionNotification();
      }
    });
  }

  void stopStudySessionNotification() {
    _sessionTimer?.cancel();
    flutterLocalNotificationsPlugin.cancel(id: 100);
  }

  Future<void> _updateSessionNotification() async {
    final int hours = _sessionSeconds ~/ 3600;
    final int minutes = (_sessionSeconds % 3600) ~/ 60;
    final String timeString =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    await flutterLocalNotificationsPlugin.show(
      100,
      'Study Session Active',
      'Time elapsed: $timeString',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_notifications',
          'Study Session',
          channelDescription: 'Active study session notifications',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'stop_session',
              'Stop Session',
              cancelNotification: false,
            ),
          ],
        ),
      ),
      payload: 'study_session',
    );
  }
}
