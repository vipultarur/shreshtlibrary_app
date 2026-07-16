import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/section_header.dart';
import 'package:shreshtlibrary/common/widgets/gallery_image_dialog.dart';

class HomeGallery extends ConsumerWidget {
  const HomeGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryImagesProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SectionHeader(
          title: l10n.library_gallery ?? 'Gallery',
          onViewAll: () {
            context.push('/gallery');
          },
        ),
        galleryAsync.when(
          data: (images) {
            if (images.isEmpty) {
              return Center(
                child: Text(
                  l10n.library_no_gallery_images ?? 'No images found',
                ),
              );
            }
            final displayImages = images.take(4).toList(); // Show max 4 images
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: displayImages.length,
                itemBuilder: (context, index) {
                  final image = displayImages[index];
                  return GestureDetector(
                    onTap: () => showGalleryImageDialog(context, image),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: image.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 120,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: 4,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: theme.brightness == Brightness.dark
                    ? Colors.white10
                    : Colors.black12,
                highlightColor: theme.brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.white24,
                child: Container(
                  height: index.isEven ? 160 : 120, // Staggered loading effect
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
