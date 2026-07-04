import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(studentApiProvider).leaderboard();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCBB9FF),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 20,
              right: 20,
            ),
            child: const Row(
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF140C2C),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF1EFFC),
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
                        if (board.isEmpty) return _buildEmptyState('No Leaderboard Data', Icons.emoji_events_outlined);
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF8B7DF1), Color(0xFF6B5CD1)]),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                                  SizedBox(height: 8),
                                  Text('Top Scholars', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: i < 3 ? Border.all(color: badgeColor, width: 2) : null,
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
                                            Text(entry.student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF140C2C))),
                                            Text(entry.levelInfo.title, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Text(entry.hoursFormatted, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF140C2C))),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const _SkeletonBox(height: 200),
                      error: (e, s) => const Center(child: Text('Failed to load leaderboard')),
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

  Widget _buildEmptyState(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF140C2C))),
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
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.white24,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
