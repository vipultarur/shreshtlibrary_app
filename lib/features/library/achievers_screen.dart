import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/library/library_screen.dart'; // For achieversProvider

class AchieversScreen extends ConsumerWidget {
  const AchieversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PageScaffold(
      title: l10n.lib_title_achievers,
      onRefresh: () async {
        ref.invalidate(achieversProvider);
      },
      child: AsyncPane(
        value: ref.watch(achieversProvider),
        builder: (achievers) {
          if (achievers.isEmpty) {
            return Center(child: Text(l10n.lib_no_achievers));
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: achievers.length,
            itemBuilder: (context, index) {
              final achiever = achievers[index];
              final isDark = theme.brightness == Brightness.dark;
              final cardColor = isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary.withValues(alpha: 0.08);

              return InkWell(
                onTap: () {
                  context.push('/achievers/${achiever.id}', extra: achiever);
                },
                borderRadius: BorderRadius.circular(20),
                child: Hero(
                  tag: 'achiever_photo_${achiever.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white60,
                              image:
                                  (achiever.photo != null &&
                                      achiever.photo!.isNotEmpty)
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        achiever.photo!,
                                        errorListener: (err) =>
                                            debugPrint('Image error: $err'),
                                      ),
                                      fit: BoxFit.contain,
                                    )
                                  : null,
                            ),
                            child:
                                (achiever.photo == null ||
                                    achiever.photo!.isEmpty)
                                ? Icon(
                                    Icons.emoji_events,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                achiever.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${achiever.achievement} (${achiever.year})',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ), // closes Column
                  ), // closes Container
                ), // closes Hero
              ); // closes InkWell
            },
          );
        },
      ),
    );
  }
}
