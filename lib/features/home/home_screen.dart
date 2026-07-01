import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

import 'package:shreshtlibrary/features/library/library_screen.dart'; // for providers
import 'package:shreshtlibrary/features/home/widgets/home_slider.dart'; // for homeSlidersProvider
import 'package:shreshtlibrary/common/widgets/status_badge.dart';
import 'package:shreshtlibrary/common/widgets/section_header.dart';
import 'package:shreshtlibrary/common/widgets/action_button_purple.dart';

final dashboardProvider = FutureProvider.autoDispose<StudentDashboard>((ref) {
  return ref.watch(studentApiProvider).dashboard();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC), // Lighter background below the curve
      body: RefreshIndicator(
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
                  color: Color(0xFFCBB9FF), // Purple top background
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildGreetingAndStatus(),
                      _buildSlider(),
                      const SizedBox(height: 12), // Reduced padding before the curve
                    ],
                  ),
                ),
              ),
                const SizedBox(height: 16),
                _buildAchievers(),
                _buildFacilities(),
              ],
            ),
          ),
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

            return ActionButtonPurple(
              label: 'Scan',
              icon: Icons.qr_code_scanner,
              onTap: () {
                if (dash != null) {
                  if (dash.restrictedFeatures.contains('attendance')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance is restricted for non-premium members.')),
                    );
                  } else {
                    context.push('/attendance/scan');
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  color: Color(0xFFD4ED5B), // Yellowish green logo circle
                  shape: BoxShape.circle,
                ),
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
                context.push('/notifications');
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
          // Logic for status badge
          String status = dashboard.membershipStatus == 'PENDING' ? 'Pending' : 'Present';
          if (dashboard.isHoliday) {
            status = 'Holiday';
          } else if (!dashboard.markedAttendanceToday) {
             status = 'Absent';
          } // Note: This logic is a placeholder. Adapt based on actual API data structure for attendance if needed.

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF140C2C),
                ),
              ),
              const SizedBox(height: 8),
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
                    time: status == 'Present' || status == 'Arrived late' ? '09:00' : null,
                  ),
                ],
              ),
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

    return slidersAsync.when(
      data: (sliders) {
        if (sliders.isEmpty) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
          height: 180,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: sliders.length,
                itemBuilder: (context, index) {
                  final slider = sliders[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5B3AE), // Grey placeholder
                      borderRadius: BorderRadius.circular(24),
                      image: slider.image != null && slider.image!.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(slider.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: (slider.image == null || slider.image!.isEmpty)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  slider.title.isEmpty ? 'title' : slider.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  slider.subtitle.isEmpty ? 'sub title' : slider.subtitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    sliders.isEmpty ? 4 : sliders.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == 0 ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == 0 ? const Color(0xFF2C2C54) : const Color(0xFF2C2C54).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAchievers() {
    final achieversAsync = ref.watch(achieversProvider);

    return Column(
      children: [
        SectionHeader(
          title: 'Achievers',
          onViewAll: () {
            // No direct route for achievers, maybe library info
            context.push('/library');
          },
        ),
        SizedBox(
          height: 180,
          child: achieversAsync.when(
            data: (achievers) {
              // Creating some dummy list if empty to match UI request (or display placeholder)
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
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFB5B3AE), // Grey placeholder for image
                                borderRadius: BorderRadius.circular(16),
                                image: (photo != null && photo.isNotEmpty)
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(photo),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                height: 24,
                                width: 90,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  achievement,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF140C2C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF140C2C),
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
            error: (_, __) => const SizedBox.shrink(),
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
            context.push('/library');
          },
        ),
        SizedBox(
          height: 100, // Matches height for the square boxes
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
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Show background through
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 3),
                            image: (photo != null && photo.isNotEmpty)
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(photo),
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
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
