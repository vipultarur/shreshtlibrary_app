import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/features/attendance/attendance_screen.dart';
import 'package:shreshtlibrary/features/attendance/qr_scanner_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/maintenance_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/login_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/register_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:shreshtlibrary/features/home/home_screen.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart';
import 'package:shreshtlibrary/features/library/achievers_screen.dart';
import 'package:shreshtlibrary/features/library/facilities_screen.dart';
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart';
import 'package:shreshtlibrary/features/payments/payments_screen.dart';
import 'package:shreshtlibrary/features/profile/profile_screen.dart';
import 'package:shreshtlibrary/features/study/leaderboard_screen.dart';
import 'package:shreshtlibrary/features/study/study_screen.dart';
import 'package:shreshtlibrary/common/widgets/app_shell.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/restricted_feature_screen.dart';

class ProtectedRoute extends ConsumerWidget {
  const ProtectedRoute({
    super.key,
    required this.feature,
    required this.child,
  });
  
  final String feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    
    return dashboardAsync.when(
      data: (dashboard) {
        if (dashboard.restrictedFeatures.contains(feature)) {
          return RestrictedFeatureScreen(dashboard: dashboard, feature: feature);
        }
        return child;
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Failed to load permissions. Please check your connection and try again.'),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final path = state.uri.path;
      final publicPath =
          path == '/login' ||
          path == '/register' ||
          path == '/forgot-password' ||
          path == '/loading';
      if (auth.isLoading) {
        return path == '/loading' ? null : '/loading';
      }
      if (auth.isMaintenance) {
        return path == '/maintenance' ? null : '/maintenance';
      }
      if (!auth.isAuthenticated && !publicPath) {
        return '/login';
      }
      if (auth.isAuthenticated && publicPath) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const ProtectedRoute(
              feature: 'attendance',
              child: AttendanceScreen(),
            ),
          ),
          GoRoute(
            path: '/study',
            builder: (context, state) => const ProtectedRoute(
              feature: 'study',
              child: StudyScreen(),
            ),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const ProtectedRoute(
              feature: 'study',
              child: LeaderboardScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/attendance/scan',
        builder: (context, state) => const ProtectedRoute(
          feature: 'attendance',
          child: QrScannerScreen(),
        ),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const ProtectedRoute(
          feature: 'payments',
          child: PaymentsScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const ProtectedRoute(
          feature: 'notifications',
          child: NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const ProtectedRoute(
          feature: 'library_info',
          child: LibraryScreen(),
        ),
      ),
      GoRoute(
        path: '/achievers',
        builder: (context, state) => const AchieversScreen(),
      ),
      GoRoute(
        path: '/facilities',
        builder: (context, state) => const FacilitiesScreen(),
      ),
    ],
  );
});

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
