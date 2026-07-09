import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(studentApiProvider).leaderboard();
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
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
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
                        if (board.isEmpty) return _buildEmptyState(l10n.leaderboard_no_data, Icons.emoji_events_outlined, theme);
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)]),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                                  const SizedBox(height: 8),
                                  Text(l10n.leaderboard_top_scholars, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: board.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 12),
                              itemBuilder: (c, i) {
                                final entry = board[i];
                                Color badgeColor = Colors.grey;
                                try {
                                  badgeColor = Color(int.parse('FF${entry.levelInfo.badgeColor.replaceAll('#', '')}', radix: 16));
                                } catch (_) {}
                                
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: i < 3 ? Border.all(color: badgeColor, width: 2) : Border.all(color: theme.dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: badgeColor.withValues(alpha: 0.1),
                                        child: Text('#${entry.rank}', style: TextStyle(color: badgeColor, fontWeight: FontWeight.w900)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(entry.student.fullName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                            Text(entry.levelInfo.title, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Text(entry.hoursFormatted, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const _SkeletonBox(height: 200),
                      error: (e, s) => Center(child: Text(l10n.leaderboard_failed_load)),
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

  Widget _buildEmptyState(String title, IconData icon, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
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
