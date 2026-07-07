import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/notifications/widgets/notification_card.dart';

final notificationsProvider =
    FutureProvider.autoDispose<List<StudentNotification>>((ref) {
      return ref.watch(studentApiProvider).notifications();
    });

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(studentApiProvider).markAllNotificationsRead();
      ref.invalidate(notificationsProvider);
      if (context.mounted) showSnack(context, 'All notifications marked as read.');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Failed to mark as read.');
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(studentApiProvider).deleteAllNotifications();
      ref.invalidate(notificationsProvider);
      if (context.mounted) showSnack(context, 'All notifications cleared.');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Failed to clear notifications.');
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

    return PageScaffold(
      title: 'Notifications',
      onRefresh: () async => ref.invalidate(notificationsProvider),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'read_all') _markAllRead(context, ref);
            if (value == 'clear_all') _clearAll(context, ref);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'read_all',
              child: Text('Mark All Read'),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: Text('Clear All'),
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
                ? const SectionCard(child: Text('No notifications yet.'))
                : Column(
                    children: rows.map((item) {
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          try {
                            await ref.read(studentApiProvider).deleteNotification(item.id);
                            ref.invalidate(notificationsProvider);
                          } catch (_) {
                            if (context.mounted) showSnack(context, 'Failed to delete notification.');
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

