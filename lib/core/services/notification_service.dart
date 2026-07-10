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

// ─── Notification Icons Helper ────────────────────────────────────────────────
String _addIconToTitle(String title, String body, String type) {
  final lowerTitle = title.toLowerCase();
  final lowerBody = body.toLowerCase();
  
  if (lowerTitle.contains('absent') || lowerBody.contains('absent')) {
    return '❌ $title';
  } else if (lowerTitle.contains('alert') || lowerBody.contains('alert') || lowerTitle.contains('warning')) {
    return '🚨 $title';
  } else if (lowerTitle.contains('present') || lowerBody.contains('present')) {
    return '✅ $title';
  } else if (type.toUpperCase() == 'ATTENDANCE') {
    return '📅 $title';
  } else if (type.toUpperCase() == 'BILLING' || type.toUpperCase() == 'EXPIRY') {
    return '💰 $title';
  } else if (type.toUpperCase() == 'ACCOUNT') {
    return '👤 $title';
  } else if (lowerTitle.contains('success')) {
    return '✅ $title';
  }
  
  return '🔔 $title';
}

// ─── Background handler (top-level, @pragma required) ────────────────────────
// This fires when the app is BACKGROUND or TERMINATED and a data-only FCM
// message arrives. It creates a local notification manually.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings =
      AndroidInitializationSettings('@drawable/ic_notification');
  await plugin.initialize(
      settings: const InitializationSettings(android: androidSettings));

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
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'attendance_notifications', 'Attendance Notifications',
      description: 'Notifications related to attendance',
      importance: Importance.max, playSound: true, enableVibration: true,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'billing_notifications', 'Billing Notifications',
      description: 'Notifications related to billing and payments',
      importance: Importance.max, playSound: true, enableVibration: true,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'account_notifications', 'Account Notifications',
      description: 'Notifications related to account status',
      importance: Importance.max, playSound: true, enableVibration: true,
    ),
  );

  String title =
      message.notification?.title ?? message.data['title'] ?? 'Shresht Library';
  final String body =
      message.notification?.body ?? message.data['body'] ?? '';
  final String subtitle = message.data['subtitle'] ?? '';
  final String imageUrl =
      message.notification?.android?.imageUrl ?? message.data['image_url'] ?? '';
  final String linkUrl = message.data['link_url'] ?? '';
  final String linkButtonText =
      (message.data['link_button_text'] ?? '').isNotEmpty
          ? message.data['link_button_text']!
          : 'View Details';

  final String type = message.data['type'] ?? 'GENERAL';
  title = _addIconToTitle(title, body, type);

  final displayBody = subtitle.isNotEmpty ? '$subtitle\n$body' : body;
  final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

  String channelId = 'default_notifications';
  String channelName = 'General Notifications';
  String channelDesc = 'General notifications like payments';

  switch (type.toUpperCase()) {
    case 'ATTENDANCE':
      channelId = 'attendance_notifications';
      channelName = 'Attendance Notifications';
      channelDesc = 'Notifications related to attendance';
      break;
    case 'BILLING':
    case 'EXPIRY':
      channelId = 'billing_notifications';
      channelName = 'Billing Notifications';
      channelDesc = 'Notifications related to billing and payments';
      break;
    case 'ACCOUNT':
      channelId = 'account_notifications';
      channelName = 'Account Notifications';
      channelDesc = 'Notifications related to account status';
      break;
    default:
      channelId = 'admin_notifications';
      channelName = 'Admin Notifications';
      channelDesc = 'Notifications from the admin';
      break;
  }

  await _showRichNotification(
    plugin: plugin,
    id: id,
    title: title,
    body: displayBody,
    imageUrl: imageUrl,
    linkUrl: linkUrl,
    linkButtonText: linkButtonText,
    channelId: channelId,
    channelName: channelName,
    channelDesc: channelDesc,
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
  String channelId = 'admin_notifications',
  String channelName = 'Admin Notifications',
  String channelDesc = 'Notifications from the admin',
}) async {
  StyleInformation? styleInformation;
  AndroidBitmap<Object>? largeIconBitmap;

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
        debugPrint('[FCM] Image downloaded successfully: ${file.path}');
        largeIconBitmap = FilePathAndroidBitmap(file.path);
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(file.path),
          hideExpandedLargeIcon: true,
          contentTitle: title,
          summaryText: body,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
        );
      } else {
        debugPrint('[FCM] File does not exist after download');
      }
    } catch (e, st) {
      debugPrint('[FCM] Image download failed for URL $imageUrl: $e\n$st');
      // Image download failed → fall back to BigText
    }
  }

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
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_notification',
        largeIcon: largeIconBitmap,
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


  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'default_notifications',
    'General Notifications',
    description: 'General notifications like payments',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _attendanceChannel =
      AndroidNotificationChannel(
    'attendance_notifications',
    'Attendance Notifications',
    description: 'Notifications related to attendance',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _billingChannel =
      AndroidNotificationChannel(
    'billing_notifications',
    'Billing Notifications',
    description: 'Notifications related to billing and payments',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _accountChannel =
      AndroidNotificationChannel(
    'account_notifications',
    'Account Notifications',
    description: 'Notifications related to account status',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<void> init() async {
    try {
      try {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      } catch (_) {}

      // Register the background handler FIRST (before anything else)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');

      await flutterLocalNotificationsPlugin.initialize(
        settings: const InitializationSettings(android: androidSettings),
        onDidReceiveNotificationResponse: (NotificationResponse r) {
          final id = r.actionId ??
              (r.payload != null ? 'payload:${r.payload}' : null);
          if (id != null) _actionStreamController.add(id);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_adminChannel);
        await androidPlugin.createNotificationChannel(_defaultChannel);
        await androidPlugin.createNotificationChannel(_attendanceChannel);
        await androidPlugin.createNotificationChannel(_billingChannel);
        await androidPlugin.createNotificationChannel(_accountChannel);
        // Request notification permission (Android 13+)
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('[FCM] Notification permission granted: $granted');
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Ensure FCM delivers messages even when app is in foreground
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // ── FOREGROUND handler ───────────────────────────────────────────────
      // When app is OPEN and a push arrives, handle it strictly via the GlobalOverlayService
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('[FCM] ✅ Foreground message received: ${message.messageId}');
        debugPrint('[FCM] Data: ${message.data}');
       
        _foregroundMessageController.add(message);
        await showSystemNotification(message);
      });

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

      // ── Token refresh listener ───────────────────────────────────────────
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed: $newToken');
      });
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
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
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

  Future<void> showSystemNotification(RemoteMessage message) async {
    String title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ?? 'GENERAL';
    title = _addIconToTitle(title, body, type);
    final payload = message.data['link_url'] ?? '';

    String channelId = 'default_notifications';
    String channelName = 'General Notifications';

    switch (type.toUpperCase()) {
      case 'ATTENDANCE':
        channelId = 'attendance_notifications';
        channelName = 'Attendance Notifications';
        break;
      case 'BILLING':
      case 'EXPIRY':
        channelId = 'billing_notifications';
        channelName = 'Billing Notifications';
        break;
      case 'ACCOUNT':
        channelId = 'account_notifications';
        channelName = 'Account Notifications';
        break;
      case 'GENERAL':
      default:
        channelId = 'default_notifications';
        channelName = 'General Notifications';
        break;
    }

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      channelId: channelId,
      channelName: channelName,
    );
  }
}
