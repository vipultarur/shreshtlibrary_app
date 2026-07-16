import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

final leaderboardProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) {
  return ref.watch(studentApiProvider).leaderboardStream();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(leaderboardProvider);
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: l10n.leaderboard_title),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(leaderboardProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: boardAsync.when(
                      data: (board) {
                        if (board.isEmpty)
                          return _buildEmptyState(
                            l10n.leaderboard_no_data,
                            Icons.emoji_events_outlined,
                            theme,
                          );
                        final top3 = board.where((e) => e.rank <= 3).toList();
                        final rest = board.where((e) => e.rank > 3).toList();

                        return Column(
                          children: [
                            if (top3.isNotEmpty) _buildPodium(top3, theme),
                            const SizedBox(height: 20),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rest.length,
                              separatorBuilder: (c, i) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (c, i) {
                                final entry = rest[i];
                                Color badgeColor = Colors.grey;
                                try {
                                  badgeColor = Color(
                                    int.parse(
                                      'FF${entry.levelInfo.badgeColor.replaceAll('#', '')}',
                                      radix: 16,
                                    ),
                                  );
                                } catch (_) {}

                                final isDark =
                                    theme.brightness == Brightness.dark;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: theme.dividerColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: badgeColor,
                                                width: 2,
                                              ),
                                              color: theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child:
                                                (entry.student.profilePhoto !=
                                                        null &&
                                                    entry
                                                        .student
                                                        .profilePhoto!
                                                        .isNotEmpty)
                                                ? CachedNetworkImage(
                                                    imageUrl: entry
                                                        .student
                                                        .profilePhoto!,
                                                    fit: BoxFit.cover,
                                                    width: 56,
                                                    height: 56,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(
                                                              Icons.person,
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                  )
                                                : Icon(
                                                    Icons.person,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    size: 32,
                                                  ),
                                          ),
                                          Positioned(
                                            bottom: -4,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: badgeColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: theme
                                                        .colorScheme
                                                        .surface,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  '#${entry.rank}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.student.fullName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: theme
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: badgeColor.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: badgeColor.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.military_tech,
                                                    size: 14,
                                                    color: badgeColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    entry.levelInfo.title,
                                                    style: TextStyle(
                                                      color: badgeColor,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            entry.hoursFormatted.split(' ')[0],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                              color: theme
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          Text(
                                            entry.hoursFormatted.contains(' ')
                                                ? entry.hoursFormatted.split(
                                                    ' ',
                                                  )[1]
                                                : 'hrs',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const _SkeletonBox(height: 200),
                      error: (e, s) =>
                          Center(child: Text(l10n.leaderboard_failed_load)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3, ThemeData theme) {
    if (top3.isEmpty) return const SizedBox();

    // Sort by rank to ensure 1, 2, 3 order just in case
    final sorted = List<LeaderboardEntry>.from(top3)
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final rank1 = sorted.isNotEmpty ? sorted[0] : null;
    final rank2 = sorted.length > 1 ? sorted[1] : null;
    final rank3 = sorted.length > 2 ? sorted[2] : null;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (rank2 != null)
            Expanded(child: _buildPodiumItem(rank2, 2, 120, theme)),
          if (rank1 != null)
            Expanded(child: _buildPodiumItem(rank1, 1, 160, theme)),
          if (rank3 != null)
            Expanded(child: _buildPodiumItem(rank3, 3, 100, theme)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardEntry entry,
    int rank,
    double podiumHeight,
    ThemeData theme,
  ) {
    Color rankColor;
    if (rank == 1)
      rankColor = const Color(0xFFFFD700);
    else if (rank == 2)
      rankColor = const Color(0xFFC0C0C0);
    else
      rankColor = const Color(0xFFCD7F32);

    final isFirst = rank == 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) Icon(Icons.workspace_premium, color: rankColor, size: 36),
        Container(
          width: isFirst ? 80 : 64,
          height: isFirst ? 80 : 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 3),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          clipBehavior: Clip.antiAlias,
          child:
              (entry.student.profilePhoto != null &&
                  entry.student.profilePhoto!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: entry.student.profilePhoto!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, color: theme.colorScheme.primary),
                )
              : Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: isFirst ? 40 : 32,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.student.fullName.split(' ').first,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isFirst ? 16 : 14,
            color: theme.textTheme.bodyLarge?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            entry.hoursFormatted,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(
              alpha: isFirst ? 0.8 : (rank == 2 ? 0.6 : 0.4),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, IconData icon, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.white24,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
