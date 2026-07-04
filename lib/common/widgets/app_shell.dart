import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexForPath(String path) {
    if (path.startsWith('/attendance')) return 1;
    if (path.startsWith('/study')) return 2;
    if (path.startsWith('/leaderboard')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = _indexForPath(path);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      body: child, // SafeArea handled by individual screens to allow full bleed if needed
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBarItem(
                iconPath: 'assets/icons/shared/home.svg',
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => context.go('/home'),
              ),
              _NavBarItem(
                iconPath: 'assets/icons/shared/calender.svg',
                label: 'Attendance',
                isSelected: currentIndex == 1,
                onTap: () => context.go('/attendance'),
              ),
              _NavBarItem(
                iconPath: 'assets/icons/shared/target.svg',
                label: 'Study',
                isSelected: currentIndex == 2,
                onTap: () => context.go('/study'),
              ),
              _NavBarItem(
                iconPath: 'assets/icons/shared/bage.svg',
                label: 'Leaderboard',
                isSelected: currentIndex == 3,
                onTap: () => context.go('/leaderboard'),
              ),
              _NavBarItem(
                iconPath: 'assets/icons/shared/profile.svg',
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF917CFF) : const Color(0xFFC4B8FF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.all(6),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFF4F2FF), // Very light purple background
                borderRadius: BorderRadius.circular(30),
              )
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
