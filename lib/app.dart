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
    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      if (route != null) {
        ref.read(routerProvider).push(route);
      }
    }
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
    );
  }
}
