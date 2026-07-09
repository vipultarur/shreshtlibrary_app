import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/routing/app_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/core/config/app_config.dart';

class OverlayNotificationData {
  final String id;
  final String title;
  final String body;
  final String? subtitle;
  final String? description;
  final String layout;
  final String? backgroundImage;
  final String? imageUrl;
  final String? linkUrl;
  final String? linkButtonText;
  final String? priority; // low, medium, high, critical
  final Duration? autoDismissDuration;
  final Map<String, dynamic> rawPayload;
  final VoidCallback? onDismissed;

  OverlayNotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.subtitle,
    this.description,
    required this.layout,
    this.backgroundImage,
    this.imageUrl,
    this.linkUrl,
    this.linkButtonText,
    this.priority = 'medium',
    this.autoDismissDuration,
    required this.rawPayload,
    this.onDismissed,
  });
}

class GlobalOverlayService {
  static final GlobalOverlayService instance = GlobalOverlayService._();
  GlobalOverlayService._();

  final Queue<OverlayNotificationData> _queue = Queue();
  final Set<String> _activeIds = {};
  OverlayNotificationData? _currentData;
  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  void show(OverlayNotificationData data) {
    if (_activeIds.contains(data.id)) return; // Prevent duplicates

    _activeIds.add(data.id);
    _queue.add(data);
    
    if (_currentEntry == null) {
      _showNext();
    }
  }

  void _showNext() {
    if (_queue.isEmpty) {
      _currentEntry = null;
      _currentData = null;
      return;
    }

    final data = _queue.removeFirst();
    _currentData = data;
    final overlayState = rootNavigatorKey.currentState?.overlay;
    if (overlayState == null) {
      // Overlay not ready, try again later or discard
      _currentEntry = null;
      return;
    }

    _currentEntry = OverlayEntry(
      builder: (context) => _OverlayWidget(
        data: data,
        onDismiss: _dismissCurrent,
      ),
    );

    overlayState.insert(_currentEntry!);

    if (data.autoDismissDuration != null) {
      _dismissTimer = Timer(data.autoDismissDuration!, () {
        _dismissCurrent();
      });
    }
  }

  void _dismissCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    
    if (_currentData != null) {
      _activeIds.remove(_currentData!.id);
      _currentData?.onDismissed?.call();
    }
    
    if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
    }

    // Small delay before showing next to allow for exit animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _showNext();
    });
  }
}

class _OverlayWidget extends StatefulWidget {
  final OverlayNotificationData data;
  final VoidCallback onDismiss;

  const _OverlayWidget({required this.data, required this.onDismiss});

  @override
  State<_OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<_OverlayWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  void _handleTap() async {
    final link = widget.data.linkUrl;
    if (link != null && link.isNotEmpty) {
      if (link.startsWith('/') && !link.contains('.pdf') && !link.startsWith('/media/')) {
        // App deep link
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null) {
          GoRouter.of(ctx).push(link);
        }
      } else {
        String finalUrl = link;
        if (link.startsWith('/')) {
           final baseUrl = AppConfig.apiBaseUrl.endsWith('/') 
               ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1) 
               : AppConfig.apiBaseUrl;
           finalUrl = '$baseUrl$link';
        }
        if (await canLaunchUrlString(finalUrl)) {
          await launchUrlString(finalUrl, mode: LaunchMode.externalApplication);
        }
      }
    }
    _handleDismiss();
  }

  @override
  Widget build(BuildContext context) {
    // Determine priority layout
    final priority = widget.data.priority?.toLowerCase() ?? 'medium';
    
    Widget content;
    if (priority == 'low') {
      content = _buildLowPriorityBanner(context);
    } else if (priority == 'critical') {
      content = _buildCriticalFullScreen(context);
    } else {
      content = _buildStandardPopup(context);
    }

    Widget overlay = SafeArea(
      child: Align(
        alignment: priority == 'low' ? Alignment.topCenter : Alignment.center,
        child: priority == 'low'
            ? SlideTransition(
                position: _slideAnimation,
                child: _buildDismissible(content),
              )
            : ScaleTransition(
                scale: _animation,
                child: _buildDismissible(content),
              ),
      ),
    );

    if (priority == 'critical') {
      return Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.8),
          child: overlay,
        ),
      );
    }

    return overlay;
  }

  Widget _buildDismissible(Widget child) {
    return Dismissible(
      key: UniqueKey(),
      direction: widget.data.priority == 'low' 
          ? DismissDirection.up 
          : DismissDirection.horizontal,
      onDismissed: (_) => widget.onDismiss(),
      child: child,
    );
  }

  Widget _buildLowPriorityBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.data.body.isNotEmpty)
                        Text(
                          widget.data.body,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _handleDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalFullScreen(BuildContext context) {
    // For critical, it takes up much more space, similar to background_image layout but forced center
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.red.shade900.withValues(alpha: 0.95),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            widget.data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: _handleTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: Text(widget.data.linkButtonText?.isNotEmpty == true ? widget.data.linkButtonText! : 'Acknowledge'),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardPopup(BuildContext context) {
    final theme = Theme.of(context);
    final isBackground = widget.data.layout == 'background_image';

    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isBackground ? theme.colorScheme.inverseSurface : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildStandardContent(context, isBackground),
            ),
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: _handleDismiss,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
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

  Widget _buildStandardContent(BuildContext context, bool isBackground) {
    if (isBackground) {
      return Stack(
        children: [
          if (widget.data.backgroundImage != null && widget.data.backgroundImage!.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.data.backgroundImage!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildTextContent(context, true),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.data.layout == 'full_image' || widget.data.layout == 'half_image') ...[
            if (widget.data.imageUrl != null && widget.data.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.data.imageUrl!,
                  height: widget.data.layout == 'full_image' ? 140 : 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),
          ],
          _buildTextContent(context, false),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isBackground) {
    final theme = Theme.of(context);
    final titleColor = isBackground ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor = isBackground ? Colors.amber.shade300 : theme.colorScheme.primary;
    final bodyColor = isBackground ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.data.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.data.subtitle != null && widget.data.subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.data.subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          widget.data.body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: bodyColor),
        ),
        if (widget.data.description != null && widget.data.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.data.description!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: bodyColor.withValues(alpha: 0.8)),
          ),
        ],
        _buildLinkButton(context, isBackground),
      ],
    );
  }

  Widget _buildLinkButton(BuildContext context, bool isBackground) {
    if (widget.data.linkUrl == null || widget.data.linkUrl!.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _handleTap,
          style: FilledButton.styleFrom(
            backgroundColor: isBackground ? theme.colorScheme.surface : theme.colorScheme.primary,
            foregroundColor: isBackground ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: Text(
            (widget.data.linkButtonText?.isNotEmpty == true) ? widget.data.linkButtonText! : 'View Details',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
