import 'package:flutter_test/flutter_test.dart';
import 'package:shreshtlibrary/core/models/models.dart';

/// Helper function implementing the Attendance & Study Session rules
/// as used in [AttendanceScreen] and [StudyScreen].
class AttendanceStudyRules {
  static bool checkShowCheckoutButton({
    required bool isHolidayFromDash,
    required String? attendanceStatusFromDash,
    required bool markedAttendanceToday,
    required AttendanceRecord? todayLog,
  }) {
    final isHoliday = isHolidayFromDash || attendanceStatusFromDash == 'Holiday';

    final isPresentOrLateFromDash = attendanceStatusFromDash == 'Present' ||
        attendanceStatusFromDash == 'Arrived Late' ||
        markedAttendanceToday;

    final isPresentOrLateFromLogs = todayLog != null &&
        todayLog.id != 0 &&
        (todayLog.isPresent || todayLog.lateMark);

    final isAbsentFromLogs = todayLog != null &&
        todayLog.id != 0 &&
        !todayLog.isPresent &&
        !todayLog.lateMark;

    final isAbsent = !isHoliday &&
        (attendanceStatusFromDash == 'Absent' || isAbsentFromLogs);

    final isPresentOrLate = !isHoliday &&
        !isAbsent &&
        (isPresentOrLateFromDash || isPresentOrLateFromLogs);

    final isCheckedOut = todayLog != null &&
        todayLog.timeOut != null &&
        todayLog.timeOut!.isNotEmpty &&
        todayLog.timeOut != '00:00:00';

    return isPresentOrLate && !isCheckedOut;
  }

  static bool checkCanStartStudySession({
    required bool isHolidayFromDash,
    required String? attendanceStatusFromDash,
    required bool markedAttendanceToday,
    required AttendanceRecord? todayLog,
  }) {
    final isHoliday = isHolidayFromDash || attendanceStatusFromDash == 'Holiday';

    final isPresentOrLateFromDash = attendanceStatusFromDash == 'Present' ||
        attendanceStatusFromDash == 'Arrived Late' ||
        markedAttendanceToday;

    final isPresentOrLateFromLogs = todayLog != null &&
        todayLog.id != 0 &&
        (todayLog.isPresent || todayLog.lateMark);

    final isAbsentFromLogs = todayLog != null &&
        todayLog.id != 0 &&
        !todayLog.isPresent &&
        !todayLog.lateMark;

    final isAbsent = !isHoliday &&
        (attendanceStatusFromDash == 'Absent' || isAbsentFromLogs);

    final isPresentOrLate = !isHoliday &&
        !isAbsent &&
        (isPresentOrLateFromDash || isPresentOrLateFromLogs);

    final isCheckedOut = todayLog != null &&
        todayLog.timeOut != null &&
        todayLog.timeOut!.isNotEmpty &&
        todayLog.timeOut != '00:00:00';

    return isPresentOrLate && !isCheckedOut;
  }
}

void main() {
  group('Attendance & Study Session Rules Tests', () {
    test('1. On Holiday: Student cannot start study session and Checkout button is not shown', () {
      final showCheckout = AttendanceStudyRules.checkShowCheckoutButton(
        isHolidayFromDash: true,
        attendanceStatusFromDash: 'Holiday',
        markedAttendanceToday: false,
        todayLog: null,
      );

      final canStartSession = AttendanceStudyRules.checkCanStartStudySession(
        isHolidayFromDash: true,
        attendanceStatusFromDash: 'Holiday',
        markedAttendanceToday: false,
        todayLog: null,
      );

      expect(showCheckout, isFalse, reason: 'Checkout button must NOT be shown on holidays');
      expect(canStartSession, isFalse, reason: 'Study session cannot start on holidays');
    });

    test('2. When Absent: Student cannot start study session and Checkout button is not shown', () {
      final showCheckout = AttendanceStudyRules.checkShowCheckoutButton(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Absent',
        markedAttendanceToday: false,
        todayLog: const AttendanceRecord(
          id: 101,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: false,
          lateMark: false,
          isManual: false,
        ),
      );

      final canStartSession = AttendanceStudyRules.checkCanStartStudySession(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Absent',
        markedAttendanceToday: false,
        todayLog: const AttendanceRecord(
          id: 101,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: false,
          lateMark: false,
          isManual: false,
        ),
      );

      expect(showCheckout, isFalse, reason: 'Checkout button must NOT be shown when absent');
      expect(canStartSession, isFalse, reason: 'Study session cannot start when absent');
    });

    test('3. When Pending (Not marked yet): Student cannot start study session and Checkout button is not shown', () {
      final showCheckout = AttendanceStudyRules.checkShowCheckoutButton(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Pending',
        markedAttendanceToday: false,
        todayLog: null,
      );

      final canStartSession = AttendanceStudyRules.checkCanStartStudySession(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Pending',
        markedAttendanceToday: false,
        todayLog: null,
      );

      expect(showCheckout, isFalse, reason: 'Checkout button must NOT be shown when pending');
      expect(canStartSession, isFalse, reason: 'Study session cannot start when pending check-in');
    });

    test('4. When Present (Marked by Attendance Maker): Shows Checkout button and Start Study Session button', () {
      final showCheckout = AttendanceStudyRules.checkShowCheckoutButton(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Present',
        markedAttendanceToday: true,
        todayLog: const AttendanceRecord(
          id: 102,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: true,
          lateMark: false,
          timeIn: '09:00:00',
          isManual: false,
        ),
      );

      final canStartSession = AttendanceStudyRules.checkCanStartStudySession(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Present',
        markedAttendanceToday: true,
        todayLog: const AttendanceRecord(
          id: 102,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: true,
          lateMark: false,
          timeIn: '09:00:00',
          isManual: false,
        ),
      );

      expect(showCheckout, isTrue, reason: 'Checkout button MUST be shown when marked Present');
      expect(canStartSession, isTrue, reason: 'Study session MUST be startable when marked Present');
    });

    test('5. When Arrived Late (Marked by Attendance Maker): Shows Checkout button and Start Study Session button', () {
      final showCheckout = AttendanceStudyRules.checkShowCheckoutButton(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Arrived Late',
        markedAttendanceToday: true,
        todayLog: const AttendanceRecord(
          id: 103,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: true,
          lateMark: true,
          timeIn: '10:30:00',
          isManual: false,
        ),
      );

      final canStartSession = AttendanceStudyRules.checkCanStartStudySession(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Arrived Late',
        markedAttendanceToday: true,
        todayLog: const AttendanceRecord(
          id: 103,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: true,
          lateMark: true,
          timeIn: '10:30:00',
          isManual: false,
        ),
      );

      expect(showCheckout, isTrue, reason: 'Checkout button MUST be shown when Arrived Late');
      expect(canStartSession, isTrue, reason: 'Study session MUST be startable when Arrived Late');
    });

    test('6. When Already Checked Out: Cannot start study session and Checkout button is hidden', () {
      final showCheckout = AttendanceStudyRules.checkShowCheckoutButton(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Present',
        markedAttendanceToday: true,
        todayLog: const AttendanceRecord(
          id: 104,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: true,
          lateMark: false,
          timeIn: '09:00:00',
          timeOut: '17:00:00',
          isManual: false,
        ),
      );

      final canStartSession = AttendanceStudyRules.checkCanStartStudySession(
        isHolidayFromDash: false,
        attendanceStatusFromDash: 'Present',
        markedAttendanceToday: true,
        todayLog: const AttendanceRecord(
          id: 104,
          studentName: 'John Doe',
          date: '2026-07-24',
          isPresent: true,
          lateMark: false,
          timeIn: '09:00:00',
          timeOut: '17:00:00',
          isManual: false,
        ),
      );

      expect(showCheckout, isFalse, reason: 'Checkout button must NOT be shown after checking out');
      expect(canStartSession, isFalse, reason: 'Study session cannot start after checking out');
    });
  });
}
