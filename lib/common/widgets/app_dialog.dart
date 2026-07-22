import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';

enum AppDialogType { info, confirm, error }

class AppDialog extends StatelessWidget {
  const AppDialog._({
    required this.title,
    required this.message,
    required this.type,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final AppDialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    AppDialogType type = AppDialogType.info,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AppDialog._(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    IconData getIcon() {
      switch (type) {
        case AppDialogType.info: return Icons.info_outline;
        case AppDialogType.confirm: return Icons.help_outline;
        case AppDialogType.error: return Icons.error_outline;
      }
    }
    
    Color getColor() {
      switch (type) {
        case AppDialogType.info: return colors.primary;
        case AppDialogType.confirm: return colors.secondary;
        case AppDialogType.error: return colors.error;
      }
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      title: Row(
        children: [
          Icon(getIcon(), color: getColor()),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        if (type == AppDialogType.confirm)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              onCancel?.call();
            },
            child: Text(cancelText ?? 'Cancel', style: TextStyle(color: colors.onSurface)),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: Text(
            confirmText ?? 'OK', 
            style: TextStyle(color: getColor(), fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }
}
