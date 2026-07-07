import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/attendance/widgets/stat_card.dart';
import 'package:shreshtlibrary/features/study/providers/study_session_provider.dart';

final attendanceLogsProvider =
    FutureProvider.autoDispose<List<AttendanceRecord>>((ref) {
  return ref.watch(studentApiProvider).attendanceLogs();
});


class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isCheckingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      appBar: CommonAppBar(
        title: 'Attendance',
        rightIcon: Consumer(
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
              mainAxisSize: MainAxisSize.min,
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
                      onPressed: _isCheckingOut ? null : () async {
                        setState(() { _isCheckingOut = true; });
                        try {
                          await ref.read(studentApiProvider).checkoutAttendance();
                          ref.invalidate(attendanceLogsProvider);
                          
                          // Stop active study session if running
                          final studyNotifier = ref.read(studySessionProvider.notifier);
                          final studyState = ref.read(studySessionProvider);
                          if (studyState.status == StudySessionStatus.active || studyState.status == StudySessionStatus.starting) {
                            await studyNotifier.stopSession();
                          }

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
                        } finally {
                          if (mounted) {
                            setState(() { _isCheckingOut = false; });
                          }
                        }
                      },
                      icon: _isCheckingOut 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.logout, size: 18),
                      label: Text(_isCheckingOut ? 'Wait...' : 'Check Out', style: const TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(attendanceLogsProvider);

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

                  final studySessions = ref.watch(studyHistoryProvider).value ?? [];
                  int monthlyStudyMinutes = 0;
                  int dailyStudyMinutes = 0;

                  for (final session in studySessions) {
                    try {
                      final start = DateTime.parse(session.startTime).toLocal();
                      if (start.month == _focusedDay.month && start.year == _focusedDay.year) {
                        monthlyStudyMinutes += session.durationMinutes;
                      }
                      if (_selectedDay != null &&
                          start.year == _selectedDay!.year &&
                          start.month == _selectedDay!.month &&
                          start.day == _selectedDay!.day) {
                        dailyStudyMinutes += session.durationMinutes;
                      }
                    } catch (_) {}
                  }
                  
                  final monthlyStudyH = monthlyStudyMinutes ~/ 60;
                  final monthlyStudyM = monthlyStudyMinutes % 60;
                  final dailyStudyH = dailyStudyMinutes ~/ 60;
                  final dailyStudyM = dailyStudyMinutes % 60;

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
                          child: _buildSelectedDayInfo(selectedLog, dailyStudyH, dailyStudyM),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildMonthlyStudyCard(monthlyStudyH, monthlyStudyM),
                        ),
                        const SizedBox(height: 12),
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

  Widget _buildMonthlyStudyCard(int hours, int minutes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1EFFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer,
              color: Color(0xFF140C2C),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${hours}h ${minutes}m',
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
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF140C2C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo(AttendanceRecord? log, int studyH, int studyM) {
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
                color: const Color(0xFFF1EFFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${studyH}h ${studyM}m',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF140C2C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Today Study',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF140C2C),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.call_received, size: 12, color: Colors.green.shade600),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.call_made, size: 12, color: Colors.red.shade600),
                          ],
                        ),
                        const SizedBox(height: 6),
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

