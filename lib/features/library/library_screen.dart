import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/library/widgets/achiever_carousel.dart';
import 'package:shreshtlibrary/features/library/widgets/review_form.dart';

final libraryInfoProvider = FutureProvider.autoDispose<LibraryInfo>(
  (ref) => ref.watch(studentApiProvider).libraryInfo(),
);
final facilitiesProvider = FutureProvider.autoDispose<List<Facility>>(
  (ref) => ref.watch(studentApiProvider).facilities(),
);
final achieversProvider = FutureProvider.autoDispose<List<Achiever>>(
  (ref) => ref.watch(studentApiProvider).achievers(),
);
final featuredAchieversProvider = FutureProvider.autoDispose<List<Achiever>>(
  (ref) => ref.watch(studentApiProvider).achievers(featured: true),
);
final reviewsProvider = FutureProvider.autoDispose<List<ReviewRecord>>(
  (ref) => ref.watch(studentApiProvider).reviews(),
);
final reviewSummaryProvider = FutureProvider.autoDispose<ReviewSummary>(
  (ref) => ref.watch(studentApiProvider).reviewSummary(),
);
final galleryImagesProvider = FutureProvider.autoDispose<List<GalleryImage>>(
  (ref) => ref.watch(studentApiProvider).galleryImages(),
);

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'Library',
      onRefresh: () async {
        ref.invalidate(libraryInfoProvider);
        ref.invalidate(facilitiesProvider);
        ref.invalidate(achieversProvider);
        ref.invalidate(featuredAchieversProvider);
        ref.invalidate(reviewsProvider);
        ref.invalidate(reviewSummaryProvider);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncPane(
              value: ref.watch(libraryInfoProvider),
              builder: (info) => SectionCard(
                title: 'Library Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (info.featureImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: info.featureImage!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (info.logoSquare != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: CachedNetworkImageProvider(info.logoSquare!),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                info.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (info.logoSquare == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          info.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (info.tagline != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(info.tagline!),
                      ),
                    if (info.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(info.description!),
                      ),
                    if (info.address != null)
                      InfoTile(
                        label: 'Address',
                        value: info.address!,
                        icon: Icons.location_on_outlined,
                      ),
                    if (info.phonePrimary != null)
                      InfoTile(
                        label: 'Phone',
                        value: info.phonePrimary!,
                        icon: Icons.phone_outlined,
                      ),
                    if (info.email != null)
                      InfoTile(
                        label: 'Email',
                        value: info.email!,
                        icon: Icons.mail_outline,
                      ),
                    if (info.whatsappNumber != null)
                      InfoTile(
                        label: 'WhatsApp',
                        value: info.whatsappNumber!,
                        icon: Icons.chat_outlined,
                      ),
                    if (info.emergencyContact != null)
                      InfoTile(
                        label: 'Emergency Contact',
                        value: info.emergencyContact!,
                        icon: Icons.warning_amber_outlined,
                      ),
                    if (info.openingTime != null && info.closingTime != null)
                      InfoTile(
                        label: 'Working Hours',
                        value: '${info.openingTime} - ${info.closingTime} ${info.weeklyOff != null ? '(Off: ${info.weeklyOff})' : ''}',
                        icon: Icons.access_time,
                      ),
                    if (info.website != null)
                      InfoTile(
                        label: 'Website',
                        value: info.website!,
                        icon: Icons.language,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(libraryInfoProvider),
              builder: (info) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (info.totalCapacity != null || info.statisticsDescription != null)
                    SectionCard(
                      title: 'Library Capacity & Stats',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.totalCapacity != null)
                            Text('Total Capacity: ${info.totalCapacity} Seats', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (info.availableSeats != null)
                            Text('Currently Available: ${info.availableSeats} Seats', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          if (info.statisticsDescription != null) ...[
                            const SizedBox(height: 8),
                            Text(info.statisticsDescription!),
                          ],
                        ],
                      ),
                    ),
                  if (info.welcomeMessage != null || info.history != null || info.mission != null || info.vision != null)
                    SectionCard(
                      title: 'About Us',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.welcomeMessage != null) ...[
                            Text(info.welcomeMessage!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                          ],
                          if (info.history != null) ...[
                            const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.history!),
                            const SizedBox(height: 12),
                          ],
                          if (info.mission != null) ...[
                            const Text('Mission', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.mission!),
                            const SizedBox(height: 12),
                          ],
                          if (info.vision != null) ...[
                            const Text('Vision', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.vision!),
                          ],
                        ],
                      ),
                    ),
                  if (info.services != null || info.coursesSupported != null) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Services & Courses',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.services != null) ...[
                            const Text('Services Offered', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.services!),
                            const SizedBox(height: 12),
                          ],
                          if (info.coursesSupported != null) ...[
                            const Text('Courses Supported', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.coursesSupported!),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (info.membershipDetails != null || info.membershipBenefits != null) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Membership Information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.membershipDetails != null) ...[
                            const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.membershipDetails!),
                            const SizedBox(height: 12),
                          ],
                          if (info.membershipBenefits != null) ...[
                            const Text('Benefits', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.membershipBenefits!),
                            const SizedBox(height: 12),
                          ],
                          if (info.registrationProcess != null) ...[
                            const Text('Registration Process', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.registrationProcess!),
                            const SizedBox(height: 12),
                          ],
                          if (info.requiredDocuments != null) ...[
                            const Text('Required Documents', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.requiredDocuments!),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (info.libraryRules != null || info.faq != null) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Rules & Guidelines',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.libraryRules != null) ...[
                            const Text('Library Rules', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.libraryRules!),
                            const SizedBox(height: 12),
                          ],
                          if (info.faq != null) ...[
                            const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(info.faq!),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (info.googleMapUrl != null && info.latitude != null && info.longitude != null) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Location',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 150,
                            child: Center(
                              child: Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Open google maps URL logic here
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Get Directions'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Facilities',
              child: AsyncPane(
                value: ref.watch(facilitiesProvider),
                builder: (rows) => rows.isEmpty
                    ? const Text('No facilities listed.')
                    : Column(
                        children: rows
                            .map(
                              (facility) => InfoTile(
                                label: facility.description ?? 'Facility',
                                value: facility.name,
                                icon: Icons.check_circle_outline,
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Featured Achievers',
              child: AsyncPane(
                value: ref.watch(featuredAchieversProvider),
                builder: (rows) => rows.isEmpty
                    ? const Text('No featured achievers yet.')
                    : AchieverCarousel(rows),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'All Achievers',
              child: AsyncPane(
                value: ref.watch(achieversProvider),
                builder: (rows) => rows.isEmpty
                    ? const Text('No achievers yet.')
                    : AchieverCarousel(rows),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Gallery',
              child: AsyncPane(
                value: ref.watch(galleryImagesProvider),
                builder: (rows) => rows.isEmpty
                    ? const Text('No images yet.')
                    : SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final image = rows[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: image.imageUrl,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Reviews',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AsyncPane(
                    value: ref.watch(reviewSummaryProvider),
                    builder: (summary) => Text(
                      '${summary.averageRating.toStringAsFixed(1)} average from ${summary.count} reviews',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ReviewForm(),
                  const SizedBox(height: 12),
                  AsyncPane(
                    value: ref.watch(reviewsProvider),
                    builder: (rows) => rows.isEmpty
                        ? const Text('No reviews yet.')
                        : Column(
                            children: rows
                                .map(
                                  (review) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      child: Text(review.rating.toString()),
                                    ),
                                    title: Text(review.studentName),
                                    subtitle: Text(review.comment),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AsyncPane(
              value: ref.watch(libraryInfoProvider),
              builder: (info) => Column(
                children: [
                  if (info.facebookUrl != null || info.instagramUrl != null || info.youtubeUrl != null || info.telegramUrl != null)
                    SectionCard(
                      title: 'Social Media',
                      child: Wrap(
                        spacing: 16,
                        children: [
                          if (info.facebookUrl != null) const Icon(Icons.facebook, size: 32),
                          if (info.instagramUrl != null) const Icon(Icons.camera_alt_outlined, size: 32),
                          if (info.youtubeUrl != null) const Icon(Icons.video_library_outlined, size: 32),
                          if (info.telegramUrl != null) const Icon(Icons.send_outlined, size: 32),
                        ],
                      ),
                    ),
                  if (info.footerText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        info.footerText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
