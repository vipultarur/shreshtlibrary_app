import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/section_header.dart';

class HomeFacilities extends ConsumerWidget {
  const HomeFacilities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          width: 140, // Increased from 100
                          height: 100, // Increased from 70
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1.5,
                            ),
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
                        SizedBox(
                          width: 140,
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
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
                      baseColor: theme.brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.black12,
                      highlightColor: theme.brightness == Brightness.dark
                          ? Colors.white24
                          : Colors.white24,
                      child: Container(
                        width: 140,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: theme.brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.black12,
                      highlightColor: theme.brightness == Brightness.dark
                          ? Colors.white24
                          : Colors.white24,
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
