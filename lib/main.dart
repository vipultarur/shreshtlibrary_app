import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_cache_service.dart';
import 'core/services/study_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final notificationService = NotificationService();
  await notificationService.init();

  final localCacheService = await LocalCacheService.init();
  
  await StudySessionService().init();
  
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
