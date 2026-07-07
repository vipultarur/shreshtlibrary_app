import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';


import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/widgets/global_overlay_service.dart';

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

      const shellRoutes = ['/home', '/attendance', '/study', '/leaderboard', '/profile'];
      
      if (action.startsWith('payload:')) {
        final payload = action.replaceFirst('payload:', '');
        if (payload.startsWith('/')) {
          if (shellRoutes.contains(payload)) {
            ref.read(routerProvider).go(payload);
          } else {
            ref.read(routerProvider).push(payload);
          }
        }
      } else if (action.startsWith('/')) {
        if (shellRoutes.contains(action)) {
          ref.read(routerProvider).go(action);
        } else {
          ref.read(routerProvider).push(action);
        }
      }
    });

    ref.read(notificationServiceProvider).foregroundMessageStream.listen((message) {
      if (rootNavigatorKey.currentContext != null) {
        final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        final subtitle = message.data['subtitle'];
        final description = message.data['description'];
        final layout = message.data['layout'] ?? 'text_only';
        final linkUrl = message.data['link_url'];
        final linkButtonText = message.data['link_button_text'];
        final imageUrl = message.notification?.android?.imageUrl ?? message.data['image_url'];
        final backgroundImage = message.data['background_image'];

        final displayMode = message.data['display_mode'];
        final type = message.data['type']?.toString().toUpperCase() ?? 'GENERAL';
        
        final router = ref.read(routerProvider);
        final currentPath = router.routerDelegate.currentConfiguration.uri.path;
        
        final isExcludedScreen = currentPath == '/notifications' || 
                                 currentPath == '/profile' || 
                                 currentPath == '/settings';

        final notifId = message.data['notification_id'] ?? message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
        
        final localCache = ref.read(localCacheServiceProvider);
        if (localCache.getProcessedNotifications().contains(notifId)) {
          debugPrint('[FCM] Notification $notifId already processed. Ignoring duplicate.');
          return;
        }
        
        if (displayMode != 'silent' && !isExcludedScreen) {
          Duration? autoDismiss;
          if (displayMode == 'one_time') {
            autoDismiss = const Duration(seconds: 8);
          }
          
          String priority = 'medium';
          if (type == 'EMERGENCY' || type == 'MAINTENANCE') {
            priority = 'critical';
          } else if (layout == 'text_only' && title.length < 20 && body.length < 50) {
            priority = 'low';
          }

          GlobalOverlayService.instance.show(
            OverlayNotificationData(
              id: notifId,
              title: title,
              body: body,
              subtitle: subtitle,
              description: description,
              layout: layout,
              imageUrl: imageUrl,
              backgroundImage: backgroundImage,
              linkUrl: linkUrl,
              linkButtonText: linkButtonText,
              priority: priority,
              autoDismissDuration: autoDismiss,
              rawPayload: message.data,
              onDismissed: () {
                localCache.markNotificationProcessed(notifId);
                debugPrint('[FCM] Notification $notifId dismissed and marked as processed.');
              },
            ),
          );
        }
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
