import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

// Core Service for managing background execution and persistent notification.
class StudySessionService {
  static final StudySessionService _instance = StudySessionService._internal();
  factory StudySessionService() => _instance;
  StudySessionService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'study_session_channel';
  static const String _channelName = 'Active Study Session';
  static const int _notificationId = 888;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Create channel
    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Tracks your active study time',
          importance: Importance.low, // Low importance for persistent (no sound)
          playSound: false,
          enableVibration: false,
        ),
      );
    }

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Study Session Active',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: [AndroidForegroundType.specialUse],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  // Exposed for UI to know if service is running
  Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}

// Background Entry Point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Handle Stop command from UI
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) async {
      await service.stopSelf();
    });
  }

  // Motion Detection Setup
  StreamSubscription? accelerometerSub;
  DateTime lastMotionTime = DateTime.now();
  
  accelerometerSub = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
    // userAccelerometerEventStream excludes gravity.
    // So any magnitude is pure physical movement of the device.
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    
    // Ignore small movements (e.g. slight jitter on table). Pickups usually > 1.5.
    if (magnitude > 1.5) {
      lastMotionTime = DateTime.now();
      
      bool isPaused = prefs.getBool('is_paused') ?? false;
      if (!isPaused) {
        // Pause session immediately on motion
        prefs.setBool('is_paused', true);
        service.invoke('update', {
          'elapsed': prefs.getInt('last_elapsed_seconds') ?? 0,
          'is_paused': true,
          'remaining_verification_seconds': 60,
          'paused_seconds': prefs.getInt('paused_seconds') ?? 0,
        });
      }
    }
  });

  // Timer loop for foreground notification and inactivity check
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        bool isPaused = prefs.getBool('is_paused') ?? false;

        // Check for inactivity (no motion) to resume session
        if (isPaused) {
          if (DateTime.now().difference(lastMotionTime).inSeconds >= 60) {
            // Resume session
            isPaused = false;
            await prefs.setBool('is_paused', false);
          }
        }

        final startTimeStr = prefs.getString('study_session_start');
        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr);
          
          if (isPaused) {
            int pausedSecs = prefs.getInt('paused_seconds') ?? 0;
            await prefs.setInt('paused_seconds', pausedSecs + 1);
            
            // Notify UI
            final elapsedSecs = prefs.getInt('last_elapsed_seconds') ?? 0;
            int remaining = 60 - DateTime.now().difference(lastMotionTime).inSeconds;
            if (remaining < 0) remaining = 0;

            service.invoke('update', {
              'elapsed': elapsedSecs, 
              'is_paused': true,
              'remaining_verification_seconds': remaining,
              'paused_seconds': pausedSecs,
            });
            
            localNotificationsPlugin.show(
              id: StudySessionService._notificationId,
              title: 'Study Paused - Motion Detected',
              body: 'Leave device still for $remaining sec to resume.',
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  StudySessionService._channelId,
                  StudySessionService._channelName,
                  icon: 'ic_notification',
                  ongoing: true,
                  playSound: false,
                  enableVibration: false,
                ),
              ),
            );
          } else {
            // Calculate active elapsed time
            int pausedSecs = prefs.getInt('paused_seconds') ?? 0;
            final elapsed = DateTime.now().difference(startTime) - Duration(seconds: pausedSecs);
            await prefs.setInt('last_elapsed_seconds', elapsed.inSeconds);
            
            String twoDigits(int n) => n.toString().padLeft(2, "0");
            String twoDigitMinutes = twoDigits(elapsed.inMinutes.remainder(60));
            String twoDigitSeconds = twoDigits(elapsed.inSeconds.remainder(60));
            String hours = elapsed.inHours > 0 ? "${twoDigits(elapsed.inHours)}:" : "";
            
            final timeStr = "$hours$twoDigitMinutes:$twoDigitSeconds";

            localNotificationsPlugin.show(
              id: StudySessionService._notificationId,
              title: 'Study Session Active',
              body: 'Elapsed: $timeStr',
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  StudySessionService._channelId,
                  StudySessionService._channelName,
                  icon: 'ic_notification',
                  ongoing: true,
                  playSound: false,
                  enableVibration: false,
                ),
              ),
            );
            
            service.invoke('update', {
              'elapsed': elapsed.inSeconds, 
              'is_paused': false,
              'paused_seconds': pausedSecs,
            });
          }
        }
      }
    }
  });

  // Cleanup on destroy
  service.on('stopService').listen((event) {
    accelerometerSub?.cancel();
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
