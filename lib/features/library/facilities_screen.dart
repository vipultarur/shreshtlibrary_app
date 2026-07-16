import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart'; // For facilitiesProvider

class FacilitiesScreen extends ConsumerWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PageScaffold(
      title: l10n.lib_title_facilities,
      onRefresh: () async {
        ref.invalidate(facilitiesProvider);
      },
      child: AsyncPane(
        value: ref.watch(facilitiesProvider),
        builder: (facilities) {
          if (facilities.isEmpty) {
            return Center(child: Text(l10n.lib_no_facilities));
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: facilities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final facility = facilities[index];
              final isDark = theme.brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (facility.image != null && facility.image!.isNotEmpty)
                      Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: facility.image!,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox(
                            height: 160,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => SizedBox(
                            height: 160,
                            child: Icon(
                              Icons.broken_image,
                              color: theme.iconTheme.color?.withValues(
                                alpha: 0.5,
                              ),
                              size: 50,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 160,
                        width: double.infinity,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: theme.iconTheme.color?.withValues(alpha: 0.5),
                          size: 50,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          if (facility.description != null &&
                              facility.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              facility.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.8),
                                height: 1.4,
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
