import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'Notifications',
      onRefresh: () async => ref.invalidate(notificationsProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncPane(
            value: ref.watch(notificationsProvider),
            builder: (rows) => rows.isEmpty
                ? const SectionCard(child: Text('No notifications yet.'))
                : Column(
                    children: rows.map((item) => NotificationCard(item)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

