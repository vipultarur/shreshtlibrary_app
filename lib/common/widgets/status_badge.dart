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

    if (upperStatus == 'PRESENT') {
      innerBgColor = const Color(0xFFE4F8E5); // Light green pill
      innerTextColor = const Color(0xFF1B6A2A); // Dark green text
    } else if (upperStatus == 'ARRIVED LATE' || upperStatus == 'LATE') {
      innerBgColor = const Color(0xFFFDEBCC); // Light orange pill
      innerTextColor = const Color(0xFF914B00); // Dark brown text
      displayStatus = 'Present (Arrived Late)';
    } else if (upperStatus == 'ABSENT') {
      innerBgColor = const Color(0xFFFDE2E2); // Light pink pill
      innerTextColor = const Color(0xFF991515); // Dark red text
    } else if (upperStatus == 'HOLIDAY') {
      innerBgColor = const Color(0xFFE2ECFA); // Light blue pill
      innerTextColor = const Color(0xFF113876); // Dark blue text
    } else if (upperStatus == 'PENDING') {
      innerBgColor = const Color(0xFFFDEBCC); // Light orange pill
      innerTextColor = const Color(0xFFD66900); // Dark orange text
    } else {
      innerBgColor = Colors.grey.shade200;
      innerTextColor = Colors.grey.shade800;
    }

    final bool hasTime = time != null && time!.isNotEmpty;
    final bool isFullPill = hasTime;
    final purpleColor = const Color(0xFF8B7DF1); // Standard purple border

    if (isFullPill) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: purpleColor, // Left side has solid purple background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: purpleColor, width: 2.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                time!,
                style: const TextStyle(
                  color: Color(0xFF140C2C),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: innerBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayStatus,
                style: TextStyle(
                  color: innerTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: innerBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: purpleColor, width: 2.5),
        ),
        child: Text(
          displayStatus,
          style: TextStyle(
            color: innerTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }
  }
}
