import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../firebase_options.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── Background handler (top-level, @pragma required) ────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings =
      AndroidInitializationSettings('@drawable/ic_notification');
  await plugin
      .initialize(const InitializationSettings(android: androidSettings));

  final androidPlugin = plugin
      .resolvePlatformSpecificImplementation<
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

  // Use notification payload first, fallback to data map
  final String title = message.notification?.title ??
      message.data['title'] ??
      'Shresht Library';
  final String body =
      message.notification?.body ?? message.data['body'] ?? '';
  final String subtitle = message.data['subtitle'] ?? '';
  final String imageUrl = message.notification?.android?.imageUrl ??
      message.data['image_url'] ?? '';
  final String linkUrl = message.data['link_url'] ?? '';
  final String linkButtonText =
      message.data['link_button_text']?.isNotEmpty == true
          ? message.data['link_button_text']!
          : 'View Details';

  // Build the display body: subtitle on first line, message body after
  final String displayBody =
      subtitle.isNotEmpty ? '$subtitle\n$body' : body;

  final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
  await _showRichNotification(
    plugin: plugin,
    id: id,
    title: title,
    body: displayBody,
    imageUrl: imageUrl,
    linkUrl: linkUrl,
    linkButtonText: linkButtonText,
  );
}

/// Downloads an image and shows a BigPicture or plain notification.
Future<void> _showRichNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required int id,
  required String title,
  required String body,
  String imageUrl = '',
  String linkUrl = '',
  String linkButtonText = 'View Details',
}) async {
  StyleInformation? styleInformation;

  // Try to download and attach the image
  if (imageUrl.isNotEmpty) {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final ext = imageUrl.split('.').last.split('?').first;
      final filePath =
          '${tempDir.path}/notif_img_$id.${ext.isEmpty ? 'jpg' : ext}';
      await dio.download(
        imageUrl,
        filePath,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );
      final file = File(filePath);
      if (await file.exists()) {
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(file.path),
          largeIcon: FilePathAndroidBitmap(file.path),
          contentTitle: title,
          summaryText: body,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
        );
      }
    } catch (_) {
      // Image download failed → fall back to BigText
    }
  }

  // Fall back to BigText so long subtitles + body are fully visible
  styleInformation ??= BigTextStyleInformation(
    body,
    contentTitle: title,
    htmlFormatBigText: false,
    htmlFormatContentTitle: false,
  );

  final List<AndroidNotificationAction> actions = [];
  if (linkUrl.isNotEmpty) {
    actions.add(AndroidNotificationAction(
      'open_link:$linkUrl',
      linkButtonText,
      showsUserInterface: true,
    ));
  }

  await plugin.show(
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
        styleInformation: styleInformation,
        actions: actions,
      ),
    ),
  );
}

// ─── Global stream controllers ────────────────────────────────────────────────
final StreamController<String> _actionStreamController =
    StreamController<String>.broadcast();
final StreamController<RemoteMessage> _foregroundMessageController =
    StreamController<RemoteMessage>.broadcast();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final id = notificationResponse.actionId ?? notificationResponse.payload;
  if (id != null) _actionStreamController.add(id);
}

// ─── NotificationService ──────────────────────────────────────────────────────
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _sessionTimer;
  int _sessionSeconds = 0;

  Stream<String> get actionStream => _actionStreamController.stream;
  Stream<RemoteMessage> get foregroundMessageStream =>
      _foregroundMessageController.stream;

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

  Future<void> init() async {
    try {
      try {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      } catch (_) {}

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');

      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: androidSettings),
        onDidReceiveNotificationResponse: (NotificationResponse r) {
          final id = r.actionId ?? (r.payload != null ? 'payload:${r.payload}' : null);
          if (id != null) _actionStreamController.add(id);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_adminChannel);
        await androidPlugin.createNotificationChannel(_sessionChannel);
        await androidPlugin.createNotificationChannel(_defaultChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // ── Foreground handler ──────────────────────────────────────────────
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message: ${message.messageId}');
        _foregroundMessageController.add(message);

        final String title = message.notification?.title ??
            message.data['title'] ??
            'Shresht Library';
        final String body =
            message.notification?.body ?? message.data['body'] ?? '';
        final String subtitle = message.data['subtitle'] ?? '';
        final String imageUrl =
            message.notification?.android?.imageUrl ??
                message.data['image_url'] ?? '';
        final String linkUrl = message.data['link_url'] ?? '';
        final String linkButtonText =
            (message.data['link_button_text'] ?? '').isNotEmpty
                ? message.data['link_button_text']!
                : 'View Details';

        final String displayBody =
            subtitle.isNotEmpty ? '$subtitle\n$body' : body;

        if (title.isNotEmpty || displayBody.isNotEmpty) {
          final int id =
              DateTime.now().millisecondsSinceEpoch.remainder(100000);
          _showRichNotification(
            plugin: flutterLocalNotificationsPlugin,
            id: id,
            title: title,
            body: displayBody,
            imageUrl: imageUrl,
            linkUrl: linkUrl,
            linkButtonText: linkButtonText,
          );
        }
      });

      // ── Tap handlers ────────────────────────────────────────────────────
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] onMessageOpenedApp: ${message.data}');
        _handleMessageTap(message);
      });

      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] getInitialMessage: ${initialMessage.data}');
        _handleMessageTap(initialMessage);
      }

      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] Token: $token');
    } catch (e, st) {
      debugPrint('[FCM] init error: $e\n$st');
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    final String linkUrl = message.data['link_url'] ?? '';
    if (linkUrl.isNotEmpty) {
      _actionStreamController.add('open_link:$linkUrl');
    } else {
      _actionStreamController.add('payload:notifications');
    }
  }

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
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: payload,
    );
  }

  // ── Study Session notification ────────────────────────────────────────────
  Future<void> startStudySessionNotification() async {
    _sessionSeconds = 0;
    _updateSessionNotification();
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      if (_sessionSeconds % 60 == 0) _updateSessionNotification();
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
