import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class ShreshtStudentApp extends ConsumerStatefulWidget {
  const ShreshtStudentApp({super.key});

  @override
  ConsumerState<ShreshtStudentApp> createState() => _ShreshtStudentAppState();
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class _ShreshtStudentAppState extends ConsumerState<ShreshtStudentApp> {
  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
    _listenToNotificationActions();
  }

  Future<void> _setupInteractedMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data.containsKey('link_url')) {
      final route = message.data['link_url'];
      if (route != null && route.toString().isNotEmpty) {
        ref.read(routerProvider).push(route.toString());
        return;
      }
    }
    
    // Default fallback to notifications screen
    ref.read(routerProvider).push('/notifications');
  }
  
  void _listenToNotificationActions() {
    ref.read(notificationServiceProvider).actionStream.listen((action) {
      if (action.startsWith('payload:')) {
        final payload = action.replaceFirst('payload:', '');
        if (payload.startsWith('/')) {
          ref.read(routerProvider).push(payload);
        }
      } else if (action.startsWith('/')) {
        ref.read(routerProvider).push(action);
      }
    });

    ref.read(notificationServiceProvider).foregroundMessageStream.listen((message) {
      if (message.notification != null) {
        final title = message.notification?.title ?? 'New Notification';
        final body = message.notification?.body ?? '';
        
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(color: Colors.white70)),
                ],
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF140C2C),
            elevation: 8,
            action: SnackBarAction(
              label: 'VIEW',
              textColor: const Color(0xFF917CFF),
              onPressed: () {
                _handleMessage(message);
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Shresht Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
    );
  }
}
