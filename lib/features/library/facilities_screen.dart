import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/common/widgets/page_scaffold.dart';
import 'package:shreshtlibrary/common/widgets/async_pane.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart'; // For facilitiesProvider

class FacilitiesScreen extends ConsumerWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'All Facilities',
      showBack: true,
      onRefresh: () async {
        ref.invalidate(facilitiesProvider);
      },
      child: AsyncPane(
        value: ref.watch(facilitiesProvider),
        builder: (facilities) {
          if (facilities.isEmpty) {
            return const Center(child: Text('No facilities listed.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: facilities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final facility = facilities[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        image: (facility.image != null && facility.image!.isNotEmpty)
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(facility.image!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (facility.image == null || facility.image!.isEmpty)
                          ? const Icon(Icons.check_circle_outline, color: Color(0xFF9CA3AF), size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF140C2C),
                            ),
                          ),
                          if (facility.description != null && facility.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              facility.description!,
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
