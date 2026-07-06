import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/config/app_config.dart';
import 'package:shreshtlibrary/core/network/api_client.dart';
import 'package:shreshtlibrary/core/network/token_store.dart';
import 'package:shreshtlibrary/core/models/models.dart';
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
  return StudentApi(ref.watch(apiClientProvider));
});

class DashboardNotifier extends AutoDisposeAsyncNotifier<StudentDashboard> {
  @override
  Future<StudentDashboard> build() {
    return ref.watch(studentApiProvider).dashboard();
  }

  void updateData(StudentDashboard dashboard) {
    state = AsyncData(dashboard);
  }
}

final dashboardProvider = AsyncNotifierProvider.autoDispose<DashboardNotifier, StudentDashboard>(DashboardNotifier.new);
