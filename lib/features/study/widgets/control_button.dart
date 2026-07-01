import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: 0.1),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Icon(
                icon, 
                size: 32, 
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
