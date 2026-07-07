import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leftIcon; // Optional custom left icon widget (replaces default back button)
  final Widget? rightIcon; // Optional action icon/widget
  final bool showBackButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leftIcon,
    this.rightIcon,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final shouldShowLeft = leftIcon != null || (showBackButton && canPop);

    return Container(
      color: const Color(0xFFCBB9FF),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (shouldShowLeft) ...[
                  leftIcon ?? Container(
                    width: 45,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF140C2C)),
                      onPressed: () {
                        if (canPop) {
                          context.pop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF140C2C),
                  ),
                ),
              ],
            ),
            ?rightIcon,
          ],
        ),
      ),
    );
  }
}
