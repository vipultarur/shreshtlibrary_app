import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.time,
  });

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

    Widget? statusIcon;
    if (upperStatus == 'PRESENT') {
      innerBgColor = const Color(0xFF7CE495); // Light green pill
      innerTextColor = const Color(0xFF140C2C); // Dark text
      statusIcon = buildIcon(const Color(0xFF07A833), Icons.check);
    } else if (upperStatus.contains('LATE')) {
      innerBgColor = const Color(0xFFFDEBCC); // Light orange pill
      innerTextColor = const Color(0xFF914B00); // Dark brown text
      displayStatus = 'Present (Arrived Late)';
      statusIcon = buildIcon(const Color(0xFFD39000), Icons.access_time_filled);
    } else if (upperStatus == 'ABSENT') {
      innerBgColor = const Color(0xFFFDE2E2); // Light pink pill
      innerTextColor = const Color(0xFF991515); // Dark red text
      statusIcon = buildIcon(const Color(0xFFD32F2F), Icons.close);
    } else if (upperStatus == 'HOLIDAY') {
      innerBgColor = const Color(0xFFE2ECFA); // Light blue pill
      innerTextColor = const Color(0xFF113876); // Dark blue text
      statusIcon = buildIcon(const Color(0xFF2864C6), Icons.beach_access);
    } else if (upperStatus == 'PENDING') {
      innerBgColor = const Color(0xFFFDEBCC); // Light orange pill
      innerTextColor = const Color(0xFFD66900); // Dark orange text
      statusIcon = buildIcon(const Color(0xFFE65100), Icons.hourglass_bottom);
    } else {
      innerBgColor = Colors.grey.shade200;
      innerTextColor = Colors.grey.shade800;
    }

    final bool hasTime = time != null && time!.isNotEmpty;
    final purpleColor = const Color(0xFF8B7DF1); // Standard purple border

    Widget buildInnerPill() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: statusIcon != null ? 6 : 14, vertical: 4),
        decoration: BoxDecoration(
          color: innerBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusIcon != null) statusIcon,
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
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), // Remove excessive padding
        decoration: BoxDecoration(
          color: purpleColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: buildInnerPill(),
      );
    }
  }
}
