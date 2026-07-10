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
import 'package:shreshtlibrary/features/auth/presentation/screens/verify_reset_otp_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/splash_screen.dart';
import 'package:shreshtlibrary/features/auth/presentation/screens/language_selection_screen.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';
import 'package:shreshtlibrary/features/home/home_screen.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart';
import 'package:shreshtlibrary/features/library/achievers_screen.dart';
import 'package:shreshtlibrary/features/library/facilities_screen.dart';
import 'package:shreshtlibrary/features/library/gallery_screen.dart';
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart';
import 'package:shreshtlibrary/features/payments/payments_screen.dart';
import 'package:shreshtlibrary/features/profile/profile_screen.dart';
import 'package:shreshtlibrary/features/study/leaderboard_screen.dart';
import 'package:shreshtlibrary/features/study/study_screen.dart';
import 'package:shreshtlibrary/common/widgets/app_shell.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/restricted_feature_screen.dart';
import 'package:shreshtlibrary/common/widgets/placeholder_screen.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

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
      error: (error, stack) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          body: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.err_failed_load_permissions ?? 'Failed to load permissions.',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.err_check_connection ?? 'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(dashboardProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n?.btn_retry ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      final cacheService = ref.read(localCacheServiceProvider);
      final hasSelectedLang = cacheService.hasSelectedLanguage();

      // Language Select Guard
      if (!hasSelectedLang && path != '/splash' && path != '/language-selection') {
        return '/language-selection';
      }

      // Prevent going back to language selection if already selected
      if (hasSelectedLang && path == '/language-selection') {
        return '/home';
      }

      final publicPath =
          path == '/login' ||
          path == '/register' ||
          path == '/forgot-password' ||
          path == '/verify-reset-otp' ||
          path == '/reset-password' ||
          path == '/maintenance' ||
          path == '/splash' ||
          path == '/language-selection';
      
      if (auth.isLoading) {
        if (path == '/splash' || path == '/language-selection') {
          return null;
        }
        return '/splash';
      }
      if (auth.isMaintenance) {
        return path == '/maintenance' ? null : '/maintenance';
      }
      
      if (!auth.isAuthenticated && !publicPath) {
        final currentUrl = Uri.encodeComponent(state.uri.toString());
        return '/login?redirect_to=$currentUrl';
      }
      
      if (auth.isAuthenticated && (path == '/login' || path == '/register' || path == '/forgot-password' || path == '/verify-reset-otp' || path == '/reset-password')) {
        final redirectTo = state.uri.queryParameters['redirect_to'];
        if (redirectTo != null && redirectTo.isNotEmpty) {
          return Uri.decodeComponent(redirectTo);
        }
        return '/home';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('The requested page "${state.uri.path}" does not exist.'),
      ),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
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
      GoRoute(
        path: '/verify-reset-otp',
        builder: (context, state) {
          final identifier = state.uri.queryParameters['identifier'] ?? '';
          return VerifyResetOtpScreen(identifier: identifier);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final identifier = state.uri.queryParameters['identifier'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(identifier: identifier, token: token);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                builder: (context, state) => const ProtectedRoute(
                  feature: 'attendance',
                  child: AttendanceScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const ProtectedRoute(
                  feature: 'study',
                  child: StudyScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const ProtectedRoute(
                  feature: 'study',
                  child: LeaderboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
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
      GoRoute(
        path: '/gallery',
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const PlaceholderScreen(title: 'Dashboard'),
      ),
      GoRoute(
        path: '/attendance/history',
        builder: (context, state) => const ProtectedRoute(
          feature: 'attendance',
          child: PlaceholderScreen(title: 'Attendance History'),
        ),
      ),
      GoRoute(
        path: '/study/history',
        builder: (context, state) => const ProtectedRoute(
          feature: 'study',
          child: PlaceholderScreen(title: 'Study History'),
        ),
      ),
      GoRoute(
        path: '/study/seat-booking',
        builder: (context, state) => const ProtectedRoute(
          feature: 'study',
          child: PlaceholderScreen(title: 'Seat Booking'),
        ),
      ),
      GoRoute(
        path: '/study/seat-booking/:seatId',
        builder: (context, state) => ProtectedRoute(
          feature: 'study',
          child: PlaceholderScreen(title: 'Seat Booking', id: state.pathParameters['seatId']),
        ),
      ),
      GoRoute(
        path: '/study/my-seat',
        builder: (context, state) => const ProtectedRoute(
          feature: 'study',
          child: PlaceholderScreen(title: 'My Seat'),
        ),
      ),
      GoRoute(
        path: '/notifications/:id',
        builder: (context, state) => ProtectedRoute(
          feature: 'notifications',
          child: PlaceholderScreen(title: 'Notification Details', id: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/payments/:id',
        builder: (context, state) => ProtectedRoute(
          feature: 'payments',
          child: PlaceholderScreen(title: 'Payment Details', id: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/membership',
        builder: (context, state) => const PlaceholderScreen(title: 'Membership'),
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlaceholderScreen(title: 'Plans'),
      ),
      GoRoute(
        path: '/library/about',
        builder: (context, state) => const PlaceholderScreen(title: 'About'),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const PlaceholderScreen(title: 'Contact'),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const PlaceholderScreen(title: 'Help'),
      ),
      GoRoute(
        path: '/faq',
        builder: (context, state) => const PlaceholderScreen(title: 'FAQ'),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PlaceholderScreen(title: 'Privacy Policy'),
      ),
      GoRoute(
        path: '/terms-conditions',
        builder: (context, state) => const PlaceholderScreen(title: 'Terms & Conditions'),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) => PlaceholderScreen(title: 'Event Details', id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/profile/account',
        builder: (context, state) => const AccountInfoScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/id-card',
        builder: (context, state) => const IdCardScreen(),
      ),
      GoRoute(
        path: '/profile/referrals',
        builder: (context, state) => const ReferralsScreen(),
      ),
    ],
  );
});

