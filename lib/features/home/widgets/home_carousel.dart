import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/features/home/widgets/home_slider.dart';

class HomeCarousel extends ConsumerStatefulWidget {
  const HomeCarousel({super.key});

  @override
  ConsumerState<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends ConsumerState<HomeCarousel> {
  int _currentSliderIndex = 0;

  @override
  Widget build(BuildContext context) {
    final slidersAsync = ref.watch(homeSlidersProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    final theme = Theme.of(context);

    final isRestricted =
        dashboardAsync.value?.restrictedFeatures.contains('sliders') ?? false;
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.85,
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slider.subtitle.isEmpty
                                ? 'sub title'
                                : slider.subtitle,
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
                        launchUrlString(
                          slider.linkUrl,
                          mode: LaunchMode.externalApplication,
                        );
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
                children: List.generate(sliders.isEmpty ? 4 : sliders.length, (
                  index,
                ) {
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
                }),
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
}
