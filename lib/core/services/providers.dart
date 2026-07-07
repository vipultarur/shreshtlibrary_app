import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/config/app_config.dart';
import 'package:shreshtlibrary/core/network/api_client.dart';
import 'package:shreshtlibrary/core/network/token_store.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/core/services/study_session_service.dart';
import 'student_api.dart';

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => const SecureTokenStore(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStore: ref.watch(tokenStoreProvider),
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
    _fetch();
    return const AsyncLoading();
  }

  Future<void> _fetch() async {
    try {
      final dashboard = await ref.watch(studentApiProvider).dashboard();
      state = AsyncData(dashboard);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void updateData(StudentDashboard dashboard) {
    state = AsyncData(dashboard);
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, AsyncValue<StudentDashboard>>(DashboardNotifier.new);
