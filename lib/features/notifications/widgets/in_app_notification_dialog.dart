import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InAppNotificationDialog extends StatelessWidget {
  const InAppNotificationDialog({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.description,
    required this.layout,
    this.backgroundImage,
    this.imageUrl,
    this.linkUrl,
    this.linkButtonText,
  });

  final String title;
  final String body;
  final String? subtitle;
  final String? description;
  final String layout; // 'text_only', 'half_image', 'full_image', 'background_image'
  final String? backgroundImage;
  final String? imageUrl;
  final String? linkUrl;
  final String? linkButtonText;

  void _launchUrl() async {
    if (linkUrl != null && linkUrl!.isNotEmpty && await canLaunchUrlString(linkUrl!)) {
      await launchUrlString(linkUrl!, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBackground = layout == 'background_image';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: isBackground ? const Color(0xFF0B0E1A) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildContent(context, isBackground),
            ),
            
            // Close Button overlapping top right
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isBackground) {
    if (isBackground) {
      return Stack(
        children: [
          if (backgroundImage != null && backgroundImage!.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: backgroundImage!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildTextAndButton(context, isBackground),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (layout == 'half_image' || layout == 'full_image') ...[
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              height: layout == 'half_image' ? 120 : 200,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
        ],
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildTextAndButton(context, isBackground),
        ),
      ],
    );
  }

  Widget _buildTextAndButton(BuildContext context, bool isBackground) {
    final theme = Theme.of(context);
    final titleColor = isBackground ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor = isBackground ? const Color(0xFFFFD54F) : theme.colorScheme.primary; // yellow-ish or primary
    final bodyColor = isBackground ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: bodyColor,
            height: 1.5,
          ),
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bodyColor.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (linkUrl != null && linkUrl!.isNotEmpty) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl();
              },
              style: FilledButton.styleFrom(
                backgroundColor: isBackground ? theme.colorScheme.surface : theme.colorScheme.primary,
                foregroundColor: isBackground ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: Text(
                (linkButtonText?.isNotEmpty == true) ? linkButtonText! : 'View Details',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
