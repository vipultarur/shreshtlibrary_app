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
    return PageScaffold(
      title: 'Attendance',
      actions: [
        IconButton(
          onPressed: () => context.push('/attendance/scan'),
          icon: const Icon(Icons.qr_code_scanner),
        ),
      ],
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
          final daysAbsent = currentMonthLogs.where((r) => !r.isPresent).length;
          final totalLateMarks = currentMonthLogs.where((r) => r.lateMark).length;
          final totalUnderTime = currentMonthLogs.where((r) => r.underTime).length;

          int totalMins = 0;
          for (final log in currentMonthLogs) {
            if (log.totalHours != null && log.totalHours!.isNotEmpty) {
              try {
                final parts = log.totalHours!.split(':');
                if (parts.length >= 2) {
                  totalMins += int.parse(parts[0]) * 60 + int.parse(parts[1]);
                } else {
                   totalMins += (double.parse(parts[0]) * 60).round();
                }
              } catch (_) {}
            }
          }
          final monthlyHours = '${totalMins ~/ 60}h ${totalMins % 60}m';

          // Build a map for quick lookup
          final logMap = <String, AttendanceRecord>{};
          for (final log in logs) {
            logMap[log.date] = log;
          }

          final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay ?? DateTime.now());
          final selectedLog = logMap[selectedDateString];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCalendar(logMap),
                const SizedBox(height: 16),
                _buildMonthlyHoursCard(monthlyHours),
                const SizedBox(height: 12),
                _buildStatsGrid(daysPresent, daysAbsent, totalLateMarks, totalUnderTime),
                const SizedBox(height: 16),
                _buildSelectedDayInfo(selectedLog),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(Map<String, AttendanceRecord> logMap) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
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
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) => _buildCell(day, logMap, isSelected: false),
            selectedBuilder: (context, day, focusedDay) => _buildCell(day, logMap, isSelected: true),
            todayBuilder: (context, day, focusedDay) => _buildCell(day, logMap, isSelected: isSameDay(day, _selectedDay), isToday: true),
            outsideBuilder: (context, day, focusedDay) => const SizedBox(),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
            weekendStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, Map<String, AttendanceRecord> logMap, {bool isSelected = false, bool isToday = false}) {
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    final log = logMap[dateString];

    Color? bgColor;
    Color textColor = Colors.black87;
    Border? border;

    if (log != null) {
      if (log.isPresent) {
        bgColor = const Color(0xFFE8F5E9); // Light Green
        textColor = const Color(0xFF2E7D32);
      } else {
        bgColor = const Color(0xFFFFEBEE); // Light Red
        textColor = const Color(0xFFC62828);
      }
    }

    if (isSelected) {
      border = Border.all(color: Colors.teal.shade100, width: 2);
      bgColor ??= Colors.teal.shade50;
    }

    return Container(
      margin: const EdgeInsets.all(6),
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
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMonthlyHoursCard(String monthlyHours) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer, color: Colors.indigo.shade400, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthlyHours,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Monthly Study Hours',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int daysPresent, int daysAbsent, int lateMarks, int underTime) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        StatCard(
          icon: Icons.how_to_reg,
          iconColor: Colors.blue,
          iconBgColor: Colors.blue.shade50,
          value: daysPresent.toString(),
          label: 'Days Present',
        ),
        StatCard(
          icon: Icons.person_off,
          iconColor: Colors.red,
          iconBgColor: Colors.red.shade50,
          value: daysAbsent.toString(),
          label: 'Days Absent',
        ),
        StatCard(
          icon: Icons.access_time,
          iconColor: Colors.purple,
          iconBgColor: Colors.purple.shade50,
          value: lateMarks.toString(),
          label: 'Late Marks',
        ),
        StatCard(
          icon: Icons.hourglass_empty,
          iconColor: Colors.orange,
          iconBgColor: Colors.orange.shade50,
          value: underTime.toString(),
          label: 'Under Time',
        ),
      ],
    );
  }

  Widget _buildSelectedDayInfo(AttendanceRecord? log) {
    String checkIn = '--:--';
    String checkOut = '--:--';
    String totalHrs = '--:--';

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
      if (log.totalHours != null && log.totalHours!.isNotEmpty) {
        totalHrs = log.totalHours!;
      }
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA), // Light cyan
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          totalHrs,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Text('Hrs', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Check-In', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 4),
                              Icon(Icons.call_received, size: 12, color: Colors.green.shade600),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(checkIn, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Check-Out', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 4),
                              Icon(Icons.call_made, size: 12, color: Colors.red.shade600),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(checkOut, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
