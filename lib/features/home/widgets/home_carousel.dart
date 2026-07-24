import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/theme/app_dimensions.dart';
import 'package:shreshtlibrary/common/widgets/app_image.dart';
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
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
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
                      borderRadius: AppDimensions.borderRadiusXl,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (slider.image != null && slider.image!.isNotEmpty)
                          AppImage(
                            urlOrPath: slider.image!,
                            type: AppImageType.network,
                            fit: BoxFit.cover,
                          ),
                        Container(
                          padding: AppDimensions.paddingAllLg,
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.spacingSm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(
                                          alpha: 0.85,
                                        ),
                                        borderRadius: AppDimensions.borderRadiusMd,
                                      ),
                                      child: Text(
                                        slider.title.isEmpty ? 'title' : slider.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimensions.spacingXs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.spacingSm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(
                                          alpha: 0.85,
                                        ),
                                        borderRadius: AppDimensions.borderRadiusMd,
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
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (slider.linkUrl.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.link, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Link',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 3),
                                      Icon(Icons.open_in_new, color: Colors.white, size: 12),
                                    ],
                                  ),
                                ),
                              ],
                            ],
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
            const SizedBox(height: AppDimensions.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs, vertical: AppDimensions.spacingXs),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                borderRadius: AppDimensions.borderRadiusXl,
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
                      borderRadius: AppDimensions.borderRadiusXs,
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
          borderRadius: AppDimensions.borderRadiusXl,
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

