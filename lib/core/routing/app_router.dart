import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/features/attendance/attendance_screen.dart';
import 'package:shreshtlibrary/features/attendance/qr_scanner_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/auth_controller.dart';
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
import 'package:shreshtlibrary/features/seats/seats_screen.dart';
import 'package:shreshtlibrary/features/study/study_screen.dart';
import 'package:shreshtlibrary/common/widgets/app_shell.dart';

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
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: '/seats',
            builder: (context, state) => const SeatsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/attendance/scan',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(path: '/study', builder: (context, state) => const StudyScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
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
