import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/models.dart';
import '../../../core/services/providers.dart';


class HomeSliderWidget extends ConsumerWidget {
  const HomeSliderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      data: (dashboard) {
        if (!dashboard.features.allowSliders) {
          return const SizedBox.shrink();
        }

        final slidersAsync = ref.watch(homeSlidersProvider);
        return slidersAsync.when(
          data: (sliders) {
            if (sliders.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 150,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
                items: sliders.map((slider) => _SliderCard(slider: slider)).toList(),
              ),
            );
          },
          loading: () => const _SliderSkeleton(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const _SliderSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({required this.slider});

  final HomeSlider slider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = slider.image != null && slider.image!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        if (slider.linkUrl.isNotEmpty) {
          final uri = Uri.parse(slider.linkUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerHighest,
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(slider.image!),
                  fit: BoxFit.contain,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slider.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (slider.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        slider.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (slider.linkUrl.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.open_in_new, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSkeleton extends StatelessWidget {
  const _SliderSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          viewportFraction: 0.9,
          enlargeCenterPage: true,
        ),
        items: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}

final homeSlidersProvider = FutureProvider.autoDispose<List<HomeSlider>>((ref) async {
  final api = ref.watch(studentApiProvider);
  return api.sliders();
});
