import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.time});

  final String status;
  final String? time;

  @override
  Widget build(BuildContext context) {
    Color innerBgColor;
    Color innerTextColor;
    String displayStatus = status;

    final String upperStatus = status.toUpperCase();

    Widget buildIcon(Color bgColor, IconData iconData) {
      return Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(iconData, size: 14, color: Colors.white),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget? statusIcon;
    if (upperStatus == 'PRESENT') {
      innerBgColor = isDark
          ? Colors.green.shade900.withValues(alpha: 0.3)
          : Colors.greenAccent.shade400; // Light green pill
      innerTextColor = isDark
          ? Colors.green.shade200
          : Colors.black87; // Dark text
      statusIcon = buildIcon(
        isDark ? Colors.green.shade600 : Colors.green.shade700,
        Icons.check,
      );
    } else if (upperStatus.contains('LATE')) {
      innerBgColor = isDark
          ? Colors.orange.shade900.withValues(alpha: 0.3)
          : Colors.orange.shade100;
      innerTextColor = isDark ? Colors.orange.shade200 : Colors.orange.shade900;
      displayStatus = 'Arrived Late';
      statusIcon = buildIcon(
        isDark ? Colors.orange.shade700 : Colors.orange.shade600,
        Icons.access_time_filled,
      );
    } else if (upperStatus == 'ABSENT') {
      innerBgColor = isDark
          ? Colors.red.shade900.withValues(alpha: 0.3)
          : Colors.red.shade100;
      innerTextColor = isDark ? Colors.red.shade200 : Colors.red.shade900;
      statusIcon = buildIcon(
        isDark ? Colors.red.shade700 : Colors.red.shade600,
        Icons.close,
      );
    } else if (upperStatus == 'HOLIDAY') {
      innerBgColor = isDark
          ? Colors.blue.shade900.withValues(alpha: 0.3)
          : Colors.blue.shade50;
      innerTextColor = isDark ? Colors.blue.shade200 : Colors.blue.shade900;
      statusIcon = buildIcon(
        isDark ? Colors.blue.shade700 : Colors.blue.shade600,
        Icons.beach_access,
      );
    } else if (upperStatus == 'PENDING') {
      innerBgColor = isDark
          ? Colors.orange.shade900.withValues(alpha: 0.3)
          : Colors.orange.shade50;
      innerTextColor = isDark ? Colors.orange.shade200 : Colors.orange.shade900;
      statusIcon = buildIcon(
        isDark ? Colors.orange.shade700 : Colors.orange.shade600,
        Icons.hourglass_bottom,
      );
    } else if (upperStatus == 'LIVE' || upperStatus == 'ACTIVE') {
      innerBgColor = isDark
          ? Colors.green.shade900.withValues(alpha: 0.3)
          : Colors.green.shade50;
      innerTextColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
      statusIcon = buildIcon(
        isDark ? Colors.green.shade700 : Colors.green.shade600,
        Icons.verified,
      );
    } else if (upperStatus == 'EXPIRED') {
      innerBgColor = isDark
          ? Colors.red.shade900.withValues(alpha: 0.3)
          : Colors.red.shade50;
      innerTextColor = isDark ? Colors.red.shade200 : Colors.red.shade900;
      statusIcon = buildIcon(
        isDark ? Colors.red.shade700 : Colors.red.shade600,
        Icons.warning_amber_rounded,
      );
    } else if (upperStatus == 'SUSPENDED') {
      innerBgColor = isDark
          ? Colors.pink.shade900.withValues(alpha: 0.3)
          : Colors.pink.shade50;
      innerTextColor = isDark ? Colors.pink.shade200 : Colors.pink.shade900;
      statusIcon = buildIcon(
        isDark ? Colors.pink.shade700 : Colors.pink.shade600,
        Icons.block,
      );
    } else {
      innerBgColor = isDark
          ? Colors.grey.shade900.withValues(alpha: 0.5)
          : Colors.grey.shade200;
      innerTextColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
    }

    final bool hasTime = time != null && time!.isNotEmpty;
    final purpleColor = theme.colorScheme.primary; // Standard primary border

    Widget buildInnerPill() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: statusIcon != null ? 6 : 14,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: innerBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?statusIcon,
            Text(
              displayStatus,
              style: TextStyle(
                color: innerTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (statusIcon != null) const SizedBox(width: 8),
          ],
        ),
      );
    }

    if (hasTime) {
      return Container(
        padding: const EdgeInsets.all(1),

        decoration: BoxDecoration(
          color: purpleColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                time!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            buildInnerPill(),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ), // Remove excessive padding
        decoration: BoxDecoration(
          color: purpleColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: buildInnerPill(),
      );
    }
  }
}
