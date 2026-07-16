import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/section_header.dart';

class HomeAchievers extends ConsumerWidget {
  const HomeAchievers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achieversAsync = ref.watch(achieversProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SectionHeader(
          title: l10n.home_achievers,
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
                return Center(child: Text(l10n.home_no_achievers));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: listCount,
                itemBuilder: (context, index) {
                  final name = achievers[index].name;
                  final photo = achievers[index].photo;
                  final achiever = achievers[index];
                  final achievement = achiever.achievement;

                  return GestureDetector(
                    onTap: () {
                      context.push(
                        '/achievers/${achiever.id}',
                        extra: achiever,
                      );
                    },
                    child: Container(
                      width: 120, // Adjusted width
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0), // Tight even border
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(22),
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
                                padding: const EdgeInsets.only(
                                  bottom: 6,
                                ), // Inner pill margin
                                child: Container(
                                  height: 22,
                                  width: 90,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          achievement,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
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
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: theme.brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  highlightColor: theme.brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.white24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
