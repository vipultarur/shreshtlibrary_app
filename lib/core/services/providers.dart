import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/config/app_config.dart';
import 'package:shreshtlibrary/core/network/api_client.dart';
import 'package:shreshtlibrary/core/network/token_store.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/core/services/study_session_service.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'student_api.dart';

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => const SecureTokenStore(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStore: ref.watch(tokenStoreProvider),
    onUnauthenticated: () {
      ref.read(authControllerProvider.notifier).handleUnauthenticated();
    },
  );
  ref.onDispose(client.close);
  return client;
});

final studentApiProvider = Provider<StudentApi>((ref) {
  return StudentApi(
    ref.watch(apiClientProvider),
    ref.watch(localCacheServiceProvider),
  );
});

final studySessionServiceProvider = Provider<StudySessionService>((ref) {
  return StudySessionService();
});

final foregroundMessageStreamProvider = StreamProvider((ref) {
  return ref.watch(notificationServiceProvider).foregroundMessageStream;
});

class DashboardNotifier extends Notifier<AsyncValue<StudentDashboard>> {
  @override
  AsyncValue<StudentDashboard> build() {
    final cache = ref.read(localCacheServiceProvider);
    // Ignore maxAge for initial load to ensure fast startup (stale-while-revalidate)
    final cachedData = cache.getCache('dashboard');

    if (cachedData != null && cachedData is Map<String, dynamic>) {
      Future.microtask(() => _fetch());
      return AsyncData(StudentDashboard.fromJson(cachedData));
    }

    _fetch();
    return const AsyncLoading();
  }

  Future<void> _fetch() async {
    StudentDashboard? dashboard;
    int retryCount = 0;
    while (true) {
      try {
        dashboard = await ref.read(studentApiProvider).dashboard();
        break;
      } catch (e, st) {
        retryCount++;
        if (retryCount >= 2) {
          if (!state.hasValue) {
            state = AsyncError(e, st);
          } else {
            // If we already have stale data, don't transition to error state
            // Just log the error and keep showing the cached data
            debugPrint('Failed to refresh dashboard data: $e');
          }
          return;
        }
        await Future<void>.delayed(Duration(seconds: 1 * retryCount));
      }
    }

    try {
      final cache = ref.read(localCacheServiceProvider);
      if (dashboard.cacheVersions != null) {
        final localVersions = cache.getCacheVersions();
        bool versionsUpdated = false;
        
        dashboard.cacheVersions!.forEach((key, remoteVersion) {
          final localVersion = localVersions[key];
          if (localVersion != remoteVersion) {
            // Version changed! Clear this specific cache so the StreamProvider is forced to fetch
            cache.clearCache(key);
            localVersions[key] = remoteVersion;
            versionsUpdated = true;
          }
        });
        
        if (versionsUpdated) {
          await cache.saveCacheVersions(localVersions);
        }
      }
      
      state = AsyncData(dashboard);
    } catch (e, st) {
      if (!state.hasValue) {
        state = AsyncError(e, st);
      }
    }
  }

  void updateData(StudentDashboard dashboard) {
    state = AsyncData(dashboard);
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, AsyncValue<StudentDashboard>>(
      DashboardNotifier.new,
    );

final myReviewProvider = StreamProvider.autoDispose<ReviewRecord?>((ref) {
  return ref.watch(studentApiProvider).myReviewStream();
});
