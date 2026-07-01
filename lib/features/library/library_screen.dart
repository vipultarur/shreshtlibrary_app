import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
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
                title: info.name,
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
                  ],
                ),
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
          ],
        ),
    );
  }
}
