import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';

enum AppButtonType { primary, secondary, outlined, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;

    Color getBackgroundColor() {
      if (effectiveDisabled) return colors.onSurface.withValues(alpha: 0.12);
      switch (type) {
        case AppButtonType.primary:
          return colors.primary;
        case AppButtonType.secondary:
          return colors.secondary;
        case AppButtonType.danger:
          return colors.error;
        case AppButtonType.outlined:
          return Colors.transparent;
      }
    }

    Color getForegroundColor() {
      if (effectiveDisabled) return colors.onSurface.withValues(alpha: 0.38);
      switch (type) {
        case AppButtonType.primary:
          return colors.onPrimary;
        case AppButtonType.secondary:
          return colors.onPrimary;
        case AppButtonType.danger:
          return colors.onError;
        case AppButtonType.outlined:
          return colors.primary;
      }
    }

    BorderSide? getBorder() {
      if (type == AppButtonType.outlined) {
        return BorderSide(
          color: effectiveDisabled 
              ? colors.onSurface.withValues(alpha: 0.12) 
              : colors.primary,
          width: 1.5,
        );
      }
      return null;
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: AppDimensions.iconSm,
            height: AppDimensions.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(getForegroundColor()),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
        ] else if (icon != null) ...[
          Icon(icon, size: AppDimensions.iconMd, color: getForegroundColor()),
          const SizedBox(width: AppDimensions.spacingSm),
        ],
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: getForegroundColor(),
          ),
        ),
      ],
    );

    final style = ElevatedButton.styleFrom(
      backgroundColor: getBackgroundColor(),
      foregroundColor: getForegroundColor(),
      disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
      elevation: 0,
      padding: AppDimensions.paddingAllMd,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusMd,
        side: getBorder() ?? BorderSide.none,
      ),
      minimumSize: const Size(double.infinity, AppDimensions.minTouchTarget),
    );

    return ElevatedButton(
      onPressed: effectiveDisabled ? null : onPressed,
      style: style,
      child: child,
    );
  }
}
