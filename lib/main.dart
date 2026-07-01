import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.init();

  final localCacheService = await LocalCacheService.init();
  
  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
        localCacheServiceProvider.overrideWithValue(localCacheService),
      ],
      child: const ShreshtStudentApp(),
    ),
  );
}
