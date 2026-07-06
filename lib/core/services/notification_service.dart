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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Handling a background message: ${message.messageId}");
}

// Ensure global stream controller for background taps, but local is easier for foreground
final StreamController<String> _actionStreamController = StreamController<String>.broadcast();
final StreamController<RemoteMessage> _foregroundMessageController = StreamController<RemoteMessage>.broadcast();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.actionId != null) {
    _actionStreamController.add(notificationResponse.actionId!);
  } else if (notificationResponse.payload != null) {
    _actionStreamController.add('payload:${notificationResponse.payload}');
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _sessionTimer;
  int _sessionSeconds = 0;
  
  Stream<String> get actionStream => _actionStreamController.stream;
  Stream<RemoteMessage> get foregroundMessageStream => _foregroundMessageController.stream;

  Future<void> init() async {
    try {
      // Initialize Firebase (Assuming flutterfire configure was run)
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint("Firebase already initialized or error: $e");
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          debugPrint('Notification tapped: ${notificationResponse.payload}');
          if (notificationResponse.actionId != null) {
            _actionStreamController.add(notificationResponse.actionId!);
          } else if (notificationResponse.payload != null) {
            _actionStreamController.add('payload:${notificationResponse.payload}');
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Create channels for different types
      const AndroidNotificationChannel adminChannel = AndroidNotificationChannel(
        'admin_notifications',
        'Admin Notifications',
        description: 'Notifications from the admin',
        importance: Importance.max,
      );

      const AndroidNotificationChannel sessionChannel = AndroidNotificationChannel(
        'session_notifications',
        'Study Session',
        description: 'Active study session notifications',
        importance: Importance.low, // low so it doesn't pop up over and over
      );
      
      const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
        'default_notifications',
        'Default Notifications',
        description: 'General notifications like payments',
        importance: Importance.high,
      );

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(adminChannel);
        await androidPlugin.createNotificationChannel(sessionChannel);
        await androidPlugin.createNotificationChannel(defaultChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      // Handle FCM foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        
        // Instead of showing system notification, broadcast it for in-app banner
        _foregroundMessageController.add(message);
      });
      
      // Request permission for FCM
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Get the token
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM Token: $token");
      // TODO: Send this token to backend when student logs in

    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_notifications',
    String channelName = 'Default Notifications',
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show Study Session Timer Notification
  Future<void> startStudySessionNotification() async {
    _sessionSeconds = 0;
    _updateSessionNotification();
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      if (_sessionSeconds % 60 == 0) { // Update notification every minute to save battery
        _updateSessionNotification();
      }
    });
  }
  
  void stopStudySessionNotification() {
    _sessionTimer?.cancel();
    flutterLocalNotificationsPlugin.cancel(id: 100); // 100 is the session notification ID
  }

  Future<void> _updateSessionNotification() async {
    final int hours = _sessionSeconds ~/ 3600;
    final int minutes = (_sessionSeconds % 3600) ~/ 60;
    
    final String timeString =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
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
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id: 100, // Fixed ID for session
      title: 'Study Session Active',
      body: 'Time elapsed: $timeString',
      notificationDetails: platformChannelSpecifics,
      payload: 'study_session',
    );
  }
}
