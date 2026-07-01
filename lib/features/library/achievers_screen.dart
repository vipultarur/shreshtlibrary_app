import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/common/widgets/page_scaffold.dart';
import 'package:shreshtlibrary/common/widgets/async_pane.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart'; // For achieversProvider

class AchieversScreen extends ConsumerWidget {
  const AchieversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'All Achievers',
      showBack: true,
      onRefresh: () async {
        ref.invalidate(achieversProvider);
      },
      child: AsyncPane(
        value: ref.watch(achieversProvider),
        builder: (achievers) {
          if (achievers.isEmpty) {
            return const Center(child: Text('No achievers listed.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: achievers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final achiever = achievers[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5B3AE),
                        borderRadius: BorderRadius.circular(12),
                        image: (achiever.photo != null && achiever.photo!.isNotEmpty)
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(achiever.photo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (achiever.photo == null || achiever.photo!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achiever.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF140C2C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${achiever.achievement} (${achiever.year})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF57534E),
                            ),
                          ),
                          if (achiever.goal != null && achiever.goal!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              achiever.goal!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF78716C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
