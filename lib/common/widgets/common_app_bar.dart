import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/core/theme/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget?
  leftIcon; // Optional custom left icon widget (replaces default back button)
  final Widget? rightIcon; // Optional action icon/widget
  final bool showBackButton;
  final bool transparent;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leftIcon,
    this.rightIcon,
    this.showBackButton = true,
    this.transparent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.canPop(context);
    final shouldShowLeft = leftIcon != null || (showBackButton && canPop);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: transparent
          ? Colors.transparent
          : (isDark
                ? AppColors.darkAppBarBg
                : theme.colorScheme.primary.withValues(alpha: 0.2)),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (shouldShowLeft) ...[
                    leftIcon ??
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark
                                  ? AppColors.darkPrimaryText
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                            onPressed: () {
                              if (canPop) {
                                context.pop();
                              }
                            },
                          ),
                        ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (rightIcon != null) ...[const SizedBox(width: 12), rightIcon!],
          ],
        ),
      ),
    );
  }
}
