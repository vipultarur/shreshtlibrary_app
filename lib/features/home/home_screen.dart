import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentSliderIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.2),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: _buildHeader(ref),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardProvider);
                ref.invalidate(homeSlidersProvider);
                ref.invalidate(facilitiesProvider);
                ref.invalidate(achieversProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.2),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreetingAndStatus(),
                          _buildSlider(),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAchievers(),
                    _buildFacilities(),
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
        child: Consumer(
          builder: (context, ref, child) {
            final dash = ref.watch(dashboardProvider).value;
            final isHoliday = dash?.isHoliday ?? false;

            if (isHoliday) {
              return ActionButtonPurple(
                label: l10n.home_holiday,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(dash?.holidayTitle ?? l10n.home_holiday),
                      content: Text(dash?.holidayDescription ?? l10n.home_holiday_desc),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.home_ok),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            bool isRestricted = dash != null && dash.restrictedFeatures.contains('attendance');
            bool isScanActive = dash != null && dash.allowQrScan;

            // Hide completely if restricted or outside of scanning time
            if (isRestricted || !isScanActive) {
              return const SizedBox.shrink();
            }

            return ActionButtonPurple(
              label: l10n.home_scan,
              icon: Icons.qr_code_scanner,
              onTap: () {
                context.push('/attendance/scan');
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final libraryInfoAsync = ref.watch(libraryInfoProvider);
    final logoUrl = libraryInfoAsync.value?.logoSquare;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
                clipBehavior: Clip.hardEdge,
                child: logoUrl != null 
                    ? Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/nlogo.png', fit: BoxFit.cover))
                    : Image.asset('assets/images/nlogo.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.app_title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkPrimaryText : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_none, color: theme.textTheme.bodyLarge?.color),
              onPressed: () {
                final dash = ref.read(dashboardProvider).value;
                if (dash != null && dash.restrictedFeatures.contains('notifications')) {
                  showRestrictionDialog(context, dash);
                } else {
                  context.push('/notifications');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingAndStatus() {
    final dashboardAsync = ref.watch(dashboardProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: dashboardAsync.when(
        data: (dashboard) {
          String status = dashboard.attendanceStatus ?? (dashboard.markedAttendanceToday ? 'Present' : 'Pending');
          if (dashboard.isHoliday) status = 'Holiday';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.home_good_morning,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                    Text(
                      dashboard.fullName.length > 9
                          ? '${dashboard.fullName.toLowerCase().substring(0, 9)}...'
                          : dashboard.fullName.toLowerCase(),
                      style: TextStyle(
                        fontSize: 22,
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 12),
                  StatusBadge(
                    status: status,
                    time: status.toLowerCase() == 'absent' ? null : dashboard.attendanceTime,
                  ),
                ],
              ),
              if (dashboard.membershipStatus == 'PENDING') ...[
                const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.orange.shade700 : Colors.orange.shade200),
                    ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: isDark ? Colors.orange.shade300 : Colors.orange.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.home_pending_activation,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.home_pending_activation_desc,
                              style: TextStyle(
                                color: isDark ? Colors.orange.shade100 : Colors.orange.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.push('/payments'),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? Colors.orange.shade900 : Colors.orange.shade100,
                          foregroundColor: isDark ? Colors.orange.shade50 : Colors.orange.shade900,
                        ),
                        child: Text(l10n.home_plans),
                      ),
                    ],
                  ),
                ),
              ] else if (dashboard.membershipStatus == 'SUSPENDED') ...[
                const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.pink.shade900.withValues(alpha: 0.3) : Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.pink.shade700 : Colors.pink.shade200),
                    ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: isDark ? Colors.pink.shade300 : Colors.pink.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.expiryDialogTitle ?? l10n.home_account_suspended,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.pink.shade200 : Colors.pink.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dashboard.expiryDialogMessage ?? l10n.home_account_suspended_desc,
                              style: TextStyle(
                                color: isDark ? Colors.pink.shade100 : Colors.pink.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (dashboard.membershipStatus == 'EXPIRED') ...[
                const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.red.shade700 : Colors.red.shade200),
                    ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: isDark ? Colors.red.shade400 : Colors.red.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.expiryDialogTitle ?? l10n.home_membership_expired,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dashboard.expiryDialogMessage ?? l10n.home_membership_expired_desc,
                              style: TextStyle(
                                color: isDark ? Colors.red.shade100 : Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.push('/payments'),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? Colors.red.shade900 : Colors.red.shade100,
                          foregroundColor: isDark ? Colors.red.shade50 : Colors.red.shade900,
                        ),
                        child: Text(l10n.home_renew),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const _SkeletonText(width: 200, height: 40),
        error: (err, stack) => Text(l10n.home_failed_load_user),
      ),
    );
  }

  Widget _buildSlider() {
    final slidersAsync = ref.watch(homeSlidersProvider);
    final dashboardAsync = ref.watch(dashboardProvider);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isRestricted = dashboardAsync.value?.restrictedFeatures.contains('sliders') ?? false;
    if (isRestricted) {
      return const SizedBox.shrink();
    }

    return slidersAsync.when(
      data: (sliders) {
        if (sliders.isEmpty) return const SizedBox.shrink();
        
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              height: 140,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 140,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  onPageChanged: (index, reason) {
                    setState(() => _currentSliderIndex = index);
                  },
                ),
                itemCount: sliders.length,
                itemBuilder: (context, index, realIndex) {
                  final slider = sliders[index];
                  Widget slideContent = Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      image: slider.image != null && slider.image!.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                slider.image!,
                                errorListener: (_) {},
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slider.title.isEmpty ? 'title' : slider.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slider.subtitle.isEmpty ? 'sub title' : slider.subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  if (slider.linkUrl.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        launchUrlString(slider.linkUrl, mode: LaunchMode.externalApplication);
                      },
                      child: slideContent,
                    );
                  }
                  return slideContent;
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sliders.isEmpty ? 4 : sliders.length,
                  (index) {
                    bool isActive = _currentSliderIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: isActive ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildAchievers() {
    final achieversAsync = ref.watch(achieversProvider);
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SectionHeader(
          title: l10n.home_achievers,
          onViewAll: () {
            context.push('/achievers');
          },
        ),
        SizedBox(
          height: 180,
          child: achieversAsync.when(
            data: (achievers) {
              final listCount = achievers.length;

              if (listCount == 0) {
                return Center(child: Text(l10n.home_no_achievers));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: listCount,
                itemBuilder: (context, index) {
                  final name = achievers[index].name;
                  final photo = achievers[index].photo;
                  final achievement = achievers[index].achievement;

                  return Container(
                    width: 120, // Adjusted width
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0), // Tight even border
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(22),
                                image: (photo != null && photo.isNotEmpty)
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          photo,
                                          errorListener: (_) {},
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 6), // Inner pill margin
                              child: Container(
                                height: 22,
                                width: 90,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        achievement,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SvgPicture.asset(
                                      'assets/icons/shared/right.svg',
                                      height: 14,
                                      width: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 0),
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                  highlightColor: theme.brightness == Brightness.dark ? Colors.white24 : Colors.white24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilities() {
    final facilitiesAsync = ref.watch(facilitiesProvider);
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SectionHeader(
          title: l10n.home_facilities,
          onViewAll: () {
            context.push('/facilities');
          },
        ),
        SizedBox(
          height: 140, // Increased height to accommodate larger cards
          child: facilitiesAsync.when(
            data: (facilities) {
              final listCount = facilities.length;

              if (listCount == 0) {
                return Center(child: Text(l10n.home_no_facilities));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: listCount,
                itemBuilder: (context, index) {
                  final name = facilities[index].name;
                  final photo = facilities[index].image;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 100, // Increased from 70
                          height: 100, // Increased from 70
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor, width: 1.5),
                            image: (photo != null && photo.isNotEmpty)
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      photo,
                                      errorListener: (_) {},
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                      highlightColor: theme.brightness == Brightness.dark ? Colors.white24 : Colors.white24,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                      highlightColor: theme.brightness == Brightness.dark ? Colors.white24 : Colors.white24,
                      child: Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SkeletonText extends StatelessWidget {
  const _SkeletonText({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.white24,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
