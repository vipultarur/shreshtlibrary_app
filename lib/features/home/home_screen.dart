import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

import 'package:shreshtlibrary/features/library/library_screen.dart'; // for providers
import 'package:shreshtlibrary/features/home/widgets/home_slider.dart'; // for homeSlidersProvider
import 'package:shreshtlibrary/core/theme/app_colors.dart';
import 'package:shreshtlibrary/common/widgets/status_badge.dart';
import 'package:shreshtlibrary/common/widgets/section_header.dart';
import 'package:shreshtlibrary/common/widgets/action_button_purple.dart';
import 'package:shreshtlibrary/common/widgets/restricted_feature_screen.dart'; // Add this for later
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart'; // for notificationsProvider
import 'package:shreshtlibrary/common/widgets/gallery_image_dialog.dart';
import 'package:shreshtlibrary/features/home/widgets/home_header.dart';
import 'package:shreshtlibrary/features/home/widgets/home_greeting_status.dart';
import 'package:shreshtlibrary/features/home/widgets/home_achievers.dart';
import 'package:shreshtlibrary/features/home/widgets/home_facilities.dart';
import 'package:shreshtlibrary/features/home/widgets/home_gallery.dart';

import 'package:shreshtlibrary/features/home/widgets/home_carousel.dart';
import 'package:shreshtlibrary/features/home/widgets/home_floating_action.dart';
import 'package:shreshtlibrary/core/services/app_review_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppReviewService.checkAndShowReviewDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.primary.withValues(
              alpha: isDark ? 0.1 : 0.2,
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: const HomeHeader(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardProvider);
                ref.invalidate(homeSlidersProvider);
                ref.invalidate(facilitiesProvider);
                ref.invalidate(achieversProvider);
                ref.invalidate(galleryImagesProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: isDark ? 0.1 : 0.2,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeGreetingStatus(),
                          const HomeCarousel(),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HomeAchievers(),
                    const HomeFacilities(),
                    const HomeGallery(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // above bottom nav
        child: const HomeFloatingAction(),
      ),
    );
  }
}
