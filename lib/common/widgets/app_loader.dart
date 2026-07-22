import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';

enum AppLoaderType { overlay, inline }

class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.type = AppLoaderType.inline,
    this.message,
  });

  final AppLoaderType type;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          Text(message!, style: theme.textTheme.bodyMedium),
        ]
      ],
    );

    if (type == AppLoaderType.overlay) {
      return Container(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        alignment: Alignment.center,
        child: loader,
      );
    }
    
    return Center(child: loader);
  }
}
