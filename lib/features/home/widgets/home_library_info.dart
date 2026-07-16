import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart';

class HomeLibraryInfoWidget extends ConsumerWidget {
  const HomeLibraryInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: 'Facilities',
          child: AsyncPane(
            value: ref.watch(facilitiesProvider),
            builder: (rows) {
              if (rows.isEmpty) {
                return const Text('No facilities listed.');
              }
              return MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final facility = rows[index];
                  // Give random height simulation for masonry effect based on index or just let the image dictate
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (facility.image != null &&
                            facility.image!.isNotEmpty)
                          Image.network(
                            facility.image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: index % 2 == 0 ? 180 : 130,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: index % 2 == 0 ? 180 : 130,
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        else
                          Container(
                            height: index % 2 == 0 ? 180 : 130,
                            color: Colors
                                .primaries[index % Colors.primaries.length]
                                .shade100,
                            child: const Center(
                              child: Icon(
                                Icons.category,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              facility.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Achievers',
          child: AsyncPane(
            value: ref.watch(achieversProvider),
            builder: (rows) => rows.isEmpty
                ? const Text('No achievers yet.')
                : Column(
                    children: rows
                        .take(5) // Show only top 5 achievers on home screen
                        .map(
                          (achiever) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: achiever.photo == null
                                ? const CircleAvatar(
                                    child: Icon(Icons.emoji_events_outlined),
                                  )
                                : CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      achiever.photo!,
                                      errorListener: (err) =>
                                          debugPrint('Image error: $err'),
                                    ),
                                  ),
                            title: Text(achiever.name),
                            subtitle: Text(
                              '${achiever.achievement} (${achiever.year})',
                            ),
                            onTap: () {
                              context.push(
                                '/achievers/${achiever.id}',
                                extra: achiever,
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Public Reviews',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AsyncPane(
                value: ref.watch(reviewSummaryProvider),
                builder: (summary) => Text(
                  '${summary.averageRating.toStringAsFixed(1)} average from ${summary.count} reviews',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              AsyncPane(
                value: ref.watch(reviewsProvider),
                builder: (rows) => rows.isEmpty
                    ? const Text('No reviews yet.')
                    : Column(
                        children: rows
                            .take(5) // Show only top 5 reviews on home screen
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
      ],
    );
  }
}
