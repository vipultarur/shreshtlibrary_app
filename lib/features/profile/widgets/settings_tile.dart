import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color? iconColor;
  final Color? textColor;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.iconColor,
    this.textColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final resolvedTextColor = isDestructive 
        ? Colors.redAccent 
        : textColor ?? (theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87));
        
    final resolvedIconColor = isDestructive 
        ? Colors.redAccent 
        : iconColor ?? resolvedTextColor;

    final iconBgColor = theme.scaffoldBackgroundColor;
    final dividerColor = theme.dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: resolvedIconColor,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: resolvedTextColor,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (!isDestructive)
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 60, right: AppDimensions.spacingMd),
              child: Divider(height: 1, color: dividerColor),
            ),
        ],
      ),
    );
  }
}
