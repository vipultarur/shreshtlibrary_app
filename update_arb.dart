import 'dart:convert';
import 'dart:io';

void main() async {
  final enFile = File('lib/core/l10n/app_en.arb');
  final hiFile = File('lib/core/l10n/app_hi.arb');
  final guFile = File('lib/core/l10n/app_gu.arb');

  final newKeys = {
    "inst_home_subtitle": "Your dashboard overview",
    "inst_attendance_subtitle": "How to check in and out",
    "inst_calendar": "Attendance",
    "inst_calendar_subtitle": "Monthly view, reports and statistics",
    "inst_calendar_desc": "View your complete attendance history in the calendar view. You can see your monthly summary, track your total present days, and analyze your punctuality over time.",
    "inst_colors": "Attendance Colors",
    "inst_colors_subtitle": "Know what each color means",
    "inst_status_subtitle": "Understand your membership state",
    "inst_study_subtitle": "Track your productive hours",
    "inst_header_title": "Your complete guide to using the app smartly.",
    "inst_home_part1": "The home screen shows your current library status. The Attendance Status Widget gives you a quick overview of your today's attendance. Use the ",
    "inst_home_scan_btn": "Scan",
    "inst_home_part2": " button to scan the QR code for Check-in and Check-out.",
    "inst_qr_desc": "QR attendance helps us mark your presence accurately. Scan the QR code displayed at the library entrance within the allowed time.",
    "inst_qr_timing": "Library Timing ",
    "inst_qr_dynamic": "(Dynamic)",
    "inst_qr_start_time": "Start Time",
    "inst_qr_allowed_time": "Allowed Time",
    "inst_qr_end_time": "End Time",
    "inst_qr_rule1_title": "Scan only once when you enter.",
    "inst_qr_rule1_desc": "Duplicate scans are not allowed.",
    "inst_qr_rule2_title": "You must scan within the allowed time.",
    "inst_qr_rule2_desc1": "After that you will be marked as ",
    "inst_qr_rule2_desc2": ".",
    "inst_qr_rule3_title": "If you come late after the allowed time, contact library staff.",
    "inst_qr_rule3_desc1": "Staff can mark you manually if permitted. Your status will show as ",
    "inst_qr_rule3_desc2": ".",
    "inst_qr_rule4_title": "Make sure your location is ON and internet is available.",
    "inst_qr_how_to": "How to Scan?",
    "inst_qr_step1_1": "Tap on ",
    "inst_qr_step1_2": " button.",
    "inst_qr_step2": "Allow camera permission.",
    "inst_qr_step3": "Point camera to the QR code.",
    "inst_qr_step4": "Wait for success message.",
    "inst_qr_step5": "Your attendance will be recorded.",
    "inst_color_present_title": "Present",
    "inst_color_present_desc": "You were marked present on time.",
    "inst_color_late_title": "Late",
    "inst_color_late_desc": "You scanned after the allowed arrival time.",
    "inst_color_absent_title": "Absent",
    "inst_color_absent_desc": "You did not attend or failed to scan your QR.",
    "inst_color_holiday_title": "Holiday",
    "inst_color_holiday_desc": "The library was closed for a holiday.",
    "inst_color_pending_title": "Pending",
    "inst_color_pending_desc": "Your attendance status is pending review.",
    "inst_status_live_title": "Live",
    "inst_status_live_desc": "You have an active membership and can use all features.",
    "inst_status_pending_title": "Pending",
    "inst_status_pending_desc": "Your membership payment is under review by staff.",
    "inst_status_suspended_title": "Suspended",
    "inst_status_suspended_desc": "Your account has been temporarily disabled by the admin.",
    "inst_status_expired_title": "Expired",
    "inst_status_expired_desc": "Your membership has ended. Please renew to access features.",
    "inst_study_desc_main": "Study Area helps you focus and track your productive study hours with beautiful analytics.",
    "inst_study_start_title": "Start Session",
    "inst_study_start_1": "Tap on ",
    "inst_study_start_btn": "Start New Session",
    "inst_study_start_2": " to begin.",
    "inst_study_pause_title": "Pause / Resume",
    "inst_study_pause_desc": "You can pause and resume anytime.",
    "inst_study_break_title": "Break Time",
    "inst_study_break_desc": "Take short breaks. App will not count break time.",
    "inst_study_end_title": "End Session",
    "inst_study_end_1": "Tap ",
    "inst_study_end_btn": "Quit",
    "inst_study_end_2": " to end your session.",
    "inst_study_analytics_title": "Analytics",
    "inst_study_analytics_desc": "View daily, weekly and monthly study analytics.",
    "inst_study_streak_title": "Focus Streak",
    "inst_study_streak_desc": "Maintain your streak and increase your focus time.",
    "inst_tips": "Tips",
    "inst_tip1": "Keep your phone away from distractions.",
    "inst_tip2": "Use break time to relax your eyes.",
    "inst_tip3": "Consistency is the key to success.",
    "inst_welcome_to": "Welcome to",
    "inst_shresht_library": "Shresht Library"
  };

  void updateArb(File file) {
    if (!file.existsSync()) return;
    final jsonStr = file.readAsStringSync();
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    
    // Add missing keys
    for (var key in newKeys.keys) {
      if (!data.containsKey(key)) {
        data[key] = newKeys[key];
      } else {
        // Force update the old ones if it's the EN file to ensure they match our new format
        if (file.path.contains('app_en.arb')) {
          data[key] = newKeys[key];
        }
      }
    }
    
    // Write back beautifully
    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(data));
  }

  updateArb(enFile);
  updateArb(hiFile);
  updateArb(guFile);
  print('Done updating ARB files.');
}
