import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/notifications/widgets/notification_card.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

final notificationsProvider =
    StreamProvider.autoDispose<List<StudentNotification>>((ref) {
      return ref.watch(studentApiProvider).notificationsStream();
    });

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(studentApiProvider).markAllNotificationsRead();
      ref.invalidate(notificationsProvider);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.noti_all_marked_read);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.noti_failed_mark);
      }
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(studentApiProvider).deleteAllNotifications();
      ref.invalidate(notificationsProvider);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.noti_all_cleared);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnack(context, l10n.noti_failed_clear);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for incoming foreground messages and refresh the list
    ref.listen(
      foregroundMessageStreamProvider,
      (previous, next) {
        if (next.hasValue) {
          ref.invalidate(notificationsProvider);
        }
      },
    );

    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.noti_title,
      onRefresh: () async => ref.invalidate(notificationsProvider),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'read_all') _markAllRead(context, ref);
            if (value == 'clear_all') _clearAll(context, ref);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'read_all',
              child: Text(l10n.noti_btn_mark_all_read),
            ),
            PopupMenuItem(
              value: 'clear_all',
              child: Text(l10n.noti_btn_clear_all),
            ),
          ],
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncPane(
            value: ref.watch(notificationsProvider),
            builder: (rows) => rows.isEmpty
                ? SectionCard(child: Text(l10n.noti_empty))
                : Column(
                    children: rows.map((item) {
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        ),
                        onDismissed: (_) async {
                          try {
                            await ref.read(studentApiProvider).deleteNotification(item.id);
                            ref.invalidate(notificationsProvider);
                          } catch (_) {
                            if (context.mounted) showSnack(context, l10n.noti_failed_delete);
                          }
                        },
                        child: NotificationCard(item),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

