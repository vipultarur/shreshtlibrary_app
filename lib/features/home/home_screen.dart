import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shreshtlibrary/features/library/library_screen.dart'; // for providers
import 'package:shreshtlibrary/features/home/widgets/home_slider.dart'; // for homeSlidersProvider
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCBB9FF),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBB9FF),
                        borderRadius: BorderRadius.only(
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
                label: 'Holiday',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(dash?.holidayTitle ?? 'Holiday'),
                      content: Text(dash?.holidayDescription ?? 'Attendance is closed today due to a holiday.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
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
              label: 'Scan',
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
    final libraryInfoAsync = ref.watch(libraryInfoProvider);
    final logoUrl = libraryInfoAsync.value?.logoSquare;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: logoUrl != null 
                    ? Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/logo.png', fit: BoxFit.cover))
                    : Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              const Text(
                'Shreshtlibrary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF140C2C),
                ),
              ),
            ],
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF140C2C)),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: dashboardAsync.when(
        data: (dashboard) {
          String status = dashboard.attendanceStatus ?? (dashboard.markedAttendanceToday ? 'Present' : 'Pending');
          if (dashboard.isHoliday) status = 'Holiday';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Moring',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF140C2C),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    dashboard.fullName.toLowerCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(
                    status: status,
                    time: dashboard.attendanceTime,
                  ),
                ],
              ),
              if (dashboard.membershipStatus == 'PENDING') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: Colors.orange.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Activation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please purchase a plan or contact admin to activate.',
                              style: TextStyle(
                                color: Colors.orange.shade800,
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
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade900,
                        ),
                        child: const Text('Plans'),
                      ),
                    ],
                  ),
                ),
              ] else if (dashboard.membershipStatus == 'SUSPENDED') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.pink.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.expiryDialogTitle ?? 'Account Suspended',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dashboard.expiryDialogMessage ?? 'Your account has been suspended by the administrator.',
                              style: TextStyle(
                                color: Colors.pink.shade800,
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.expiryDialogTitle ?? 'Membership Expired',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dashboard.expiryDialogMessage ?? 'Your membership has expired. Please renew to continue accessing library features.',
                              style: TextStyle(
                                color: Colors.red.shade800,
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
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                        child: const Text('Renew'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const _SkeletonText(width: 200, height: 40),
        error: (err, stack) => const Text('Failed to load user info'),
      ),
    );
  }

  Widget _buildSlider() {
    final slidersAsync = ref.watch(homeSlidersProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

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
                      color: const Color(0xFFB5B3AE), // Grey placeholder
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
                            color: const Color(0xFF8B7DF1).withValues(alpha: 0.85), // Primary color pill
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
                            color: const Color(0xFF8B7DF1).withValues(alpha: 0.85),
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
                color: const Color(0xFF8B7DF1).withValues(alpha: 0.7),
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
                        color: const Color(0xFF2E1F63),
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

    return Column(
      children: [
        SectionHeader(
          title: 'Achievers',
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
                return const Center(child: Text('No achievers yet.'));
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28), // Perfectly rounded card
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0), // Tight even border
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFAFAEA9), // Exact grey from image
                                borderRadius: BorderRadius.circular(22), // Matching inner radius
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
                                  color: const Color(0xFF7CE495), // Light green pill
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
                                          color: Color(0xFF140C2C), // Dark text color
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
                              style: const TextStyle(
                                color: Color(0xFF1E2442), // Exact dark blue text
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilities() {
    final facilitiesAsync = ref.watch(facilitiesProvider);

    return Column(
      children: [
        SectionHeader(
          title: 'Facilities',
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
                return const Center(child: Text('No facilities available.'));
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
                            color: Colors.transparent, // Show background through
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 3),
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
                          style: const TextStyle(
                            color: Color(0xFF140C2C),
                            fontWeight: FontWeight.bold,
                            fontSize: 13, // Increased from 12
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
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
