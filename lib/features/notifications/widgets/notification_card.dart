import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/notifications/notifications_screen.dart'; // For notificationsProvider

class NotificationCard extends ConsumerWidget {
  const NotificationCard(this.item, {super.key});

  final StudentNotification item;

  Future<void> _markRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(studentApiProvider).markNotificationRead(item.id);
      ref.invalidate(notificationsProvider);
      if (context.mounted) showSnack(context, 'Marked as read.');
    } on ApiFailure catch (failure) {
      if (context.mounted) showSnack(context, failure.message);
    }
  }

  void _launchUrl(String url) async {
    if (url.isNotEmpty && await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      // Parse the ISO 8601 string (which will be in UTC if 'Z' is present)
      // If the backend is still returning the old format, it will throw FormatException and fall back to returning the string directly.
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUnread = !item.isRead;

    Widget content;
    switch (item.layout) {
      case 'background_image':
        content = _buildBackgroundImageLayout(context);
        break;
      case 'full_image':
        content = _buildFullImageLayout(context);
        break;
      case 'half_image':
        content = _buildHalfImageLayout(context);
        break;
      case 'text_only':
      default:
        content = _buildTextOnlyLayout(context);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isUnread ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isUnread ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isUnread ? 2 : 1,
          ),
        ),
        color: isUnread ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            content,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(item.sentAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (item.displayMode != 'one_time')
                    isUnread
                        ? TextButton.icon(
                            onPressed: () => _markRead(context, ref),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Mark Read'),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          )
                        : Icon(Icons.done_all, color: theme.colorScheme.primary, size: 18),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextOnlyLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Text(item.body),
          _buildRichDescription(context),
          _buildLinkButton(context),
        ],
      ),
    );
  }

  Widget _buildHalfImageLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (item.images.isNotEmpty)
          Image.network(
            item.images.first,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Text(item.body),
              _buildRichDescription(context),
              _buildLinkButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullImageLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Text(item.body),
              _buildRichDescription(context),
            ],
          ),
        ),
        if (item.images.isNotEmpty)
          Image.network(
            item.images.first,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        if (item.linkUrl != null && item.linkUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLinkButton(context),
          ),
      ],
    );
  }

  Widget _buildBackgroundImageLayout(BuildContext context) {
    return Stack(
      children: [
        if (item.backgroundImage != null)
          Positioned.fill(
            child: Image.network(
              item.backgroundImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty)
                  Text(
                    item.subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                const SizedBox(height: 12),
                Text(item.body, style: const TextStyle(color: Colors.white)),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(item.description!, style: const TextStyle(color: Colors.white70)),
                ],
                _buildLinkButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (item.subtitle != null && item.subtitle!.isNotEmpty)
          Text(
            item.subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
      ],
    );
  }

  Widget _buildRichDescription(BuildContext context) {
    if (item.description == null || item.description!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        item.description!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context) {
    if (item.linkUrl == null || item.linkUrl!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: FilledButton.icon(
        onPressed: () => _launchUrl(item.linkUrl!),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(item.linkButtonText?.isNotEmpty == true ? item.linkButtonText! : 'View Details'),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          backgroundColor: item.layout == 'background_image' ? Colors.white : Theme.of(context).colorScheme.primary,
          foregroundColor: item.layout == 'background_image' ? Colors.black : Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
