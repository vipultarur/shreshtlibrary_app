import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/attendance/widgets/stat_card.dart';

final attendanceLogsProvider =
    FutureProvider.autoDispose<List<AttendanceRecord>>((ref) {
  return ref.watch(studentApiProvider).attendanceLogs();
});

final attendanceStudyHistoryProvider =
    FutureProvider.autoDispose<List<StudySession>>((ref) {
  return ref.watch(studentApiProvider).studySessionHistory();
});

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCBB9FF),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF140C2C)),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF140C2C),
                        ),
                      ),
                    ],
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final dash = ref.watch(dashboardProvider).value;
                      final isRestricted = dash?.restrictedFeatures.contains('attendance') ?? false;
                      final showScan = !isRestricted && (dash?.allowQrScan ?? false);
                      
                      final logsOpt = ref.watch(attendanceLogsProvider).value;
                      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      final todayLog = logsOpt?.firstWhere(
                          (l) => l.date == todayStr,
                          orElse: () => AttendanceRecord(id: 0, studentName: '', date: '', isPresent: false, isManual: false));
                          
                      final isCheckedIn = todayLog != null && todayLog.isPresent && todayLog.timeIn != null;
                      final isCheckedOut = todayLog != null && todayLog.timeOut != null;

                      return Row(
                        children: [
                          if (isCheckedIn && !isCheckedOut)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF140C2C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () async {
                                  try {
                                    await ref.read(studentApiProvider).checkoutAttendance();
                                    ref.invalidate(attendanceLogsProvider);
                                    ref.invalidate(attendanceStudyHistoryProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Checked out successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Check Out', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          if (showScan)
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF140C2C)),
                                onPressed: () => context.push('/attendance/scan'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(attendanceLogsProvider);
                ref.invalidate(attendanceStudyHistoryProvider);
              },
              child: AsyncPane(
                value: ref.watch(attendanceLogsProvider),
                builder: (logs) {
                  final currentMonthLogs = logs.where((r) {
                    try {
                      final date = DateTime.parse(r.date);
                      return date.month == _focusedDay.month && date.year == _focusedDay.year;
                    } catch (_) {
                      return false;
                    }
                  }).toList();

                  final daysPresent = currentMonthLogs.where((r) => r.isPresent).length;
                  final daysAbsent = currentMonthLogs.where((r) => !r.isPresent && r.method != 'PENDING').length;
                  final totalLateMarks = currentMonthLogs.where((r) => r.lateMark).length;




                  final studyHistory = ref.watch(attendanceStudyHistoryProvider).value ?? [];
                  
                  int dailyStudyMins = 0;
                  int monthlyStudyMins = 0;
                  final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDay ?? DateTime.now());
                  
                  for (final session in studyHistory) {
                    try {
                      final sessionDate = DateTime.parse(session.startTime);
                      final sessionDateStr = DateFormat('yyyy-MM-dd').format(sessionDate);
                      
                      if (sessionDateStr == selectedDateStr) {
                        dailyStudyMins += session.durationMinutes;
                      }
                      
                      if (sessionDate.month == _focusedDay.month && sessionDate.year == _focusedDay.year) {
                        monthlyStudyMins += session.durationMinutes;
                      }
                    } catch (_) {}
                  }
                  
                  final dailyStudyHours = '${dailyStudyMins ~/ 60}h ${dailyStudyMins % 60}m';
                  final monthlyStudyHours = '${monthlyStudyMins ~/ 60}h ${monthlyStudyMins % 60}m';

                  // Build a map for quick lookup
                  final logMap = <String, AttendanceRecord>{};
                  for (final log in logs) {
                    logMap[log.date] = log;
                  }

                  final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay ?? DateTime.now());
                  final selectedLog = logMap[selectedDateString];

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFCBB9FF),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildCalendar(logMap),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSelectedDayInfo(selectedLog, dailyStudyHours),
                        ),
                        const SizedBox(height: 8),
                        _buildMonthlyHoursCard(monthlyStudyHours),
                        const SizedBox(height: 4),
                        _buildStatsGrid(daysPresent, daysAbsent, totalLateMarks),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Map<String, AttendanceRecord> logMap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        rowHeight: 38,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF140C2C), size: 20),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF140C2C), size: 20),
          headerPadding: EdgeInsets.symmetric(vertical: 4),
          titleTextStyle: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w900,
            color: Color(0xFF140C2C),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildCell(day, logMap, isSelected: false),
          selectedBuilder: (context, day, focusedDay) => _buildCell(day, logMap, isSelected: true),
          todayBuilder: (context, day, focusedDay) => _buildCell(day, logMap, isSelected: isSameDay(day, _selectedDay), isToday: true),
          outsideBuilder: (context, day, focusedDay) => const SizedBox(),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.w600, fontSize: 12),
          weekendStyle: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, Map<String, AttendanceRecord> logMap, {bool isSelected = false, bool isToday = false}) {
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    final log = logMap[dateString];

    Color? bgColor;
    Color textColor = const Color(0xFF140C2C);
    Border? border;

    if (log != null) {
      if (log.isPresent) {
        if (log.lateMark) {
          bgColor = const Color(0xFFFFF3E0); // Light orange for late
          textColor = const Color(0xFFE65100);
        } else {
          bgColor = const Color(0xFFE8F5E9); // Light Green
          textColor = const Color(0xFF2E7D32);
        }
      } else if (log.method == 'PENDING') {
        bgColor = const Color(0xFFFFF8E1); // Light yellow for pending
        textColor = const Color(0xFFF57F17);
      } else {
        bgColor = const Color(0xFFFFEBEE); // Light Red for absent
        textColor = const Color(0xFFC62828);
      }
    }

    if (isSelected) {
      border = Border.all(color: const Color(0xFF8B7DF1), width: 1.5);
      bgColor ??= const Color(0xFFCBB9FF).withValues(alpha: 0.3);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMonthlyHoursCard(String monthlyHours) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBB9FF).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer, color: Color(0xFF140C2C), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthlyHours,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF140C2C),
                  ),
                ),
                const Text(
                  'Monthly Study Hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF140C2C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int daysPresent, int daysAbsent, int lateMarks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.how_to_reg,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.shade50,
                  value: daysPresent.toString(),
                  label: 'Days Present',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.person_off,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.shade50,
                  value: daysAbsent.toString(),
                  label: 'Days Absent',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.access_time,
                  iconColor: Colors.purple,
                  iconBgColor: Colors.purple.shade50,
                  value: lateMarks.toString(),
                  label: 'Late Marks',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo(AttendanceRecord? log, String dailyStudyHours) {
    String checkIn = '--:--';
    String checkOut = '--:--';


    if (log != null && log.isPresent) {
      if (log.timeIn != null) {
        try {
          final parts = log.timeIn!.split(':');
          if (parts.length >= 2) {
             final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
             final now = DateTime.now();
             final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
             checkIn = DateFormat('hh:mm a').format(dt);
          }
        } catch (_) {
          checkIn = log.timeIn!;
        }
      }
      if (log.timeOut != null) {
        try {
          final parts = log.timeOut!.split(':');
          if (parts.length >= 2) {
             final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
             final now = DateTime.now();
             final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
             checkOut = DateFormat('hh:mm a').format(dt);
          }
        } catch (_) {
          checkOut = log.timeOut!;
        }
      }

    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFCBB9FF).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        dailyStudyHours,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF140C2C),
                        ),
                      ),
                    ],
                  ),
                  const Text('TodayStudy', style: TextStyle(color: Color(0xFF140C2C), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF1EFFC), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Check-In', 
                              style: TextStyle(
                                fontSize: 10, 
                                color: Color(0xFF140C2C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.call_received, size: 12, color: Colors.green.shade600),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkIn, 
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF140C2C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF1EFFC), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Check-Out', 
                              style: TextStyle(
                                fontSize: 10, 
                                color: Color(0xFF140C2C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.call_made, size: 12, color: Colors.red.shade600),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkOut, 
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF140C2C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

