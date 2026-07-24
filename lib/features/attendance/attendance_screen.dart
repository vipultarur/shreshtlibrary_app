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
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/theme/app_colors.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';

class FocusedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void update(DateTime newDate) => state = newDate;
}

final focusedMonthProvider = NotifierProvider.autoDispose<FocusedMonthNotifier, DateTime>(
  FocusedMonthNotifier.new,
);

final attendanceLogsProvider =
    StreamProvider.autoDispose<List<AttendanceRecord>>((ref) {
      final focusedMonth = ref.watch(focusedMonthProvider);
      return ref.watch(studentApiProvider).attendanceLogsStream(
        year: focusedMonth.year,
        month: focusedMonth.month,
      );
    });

final holidaysProvider = StreamProvider.autoDispose<List<HolidayRecord>>((ref) {
  return ref.watch(studentApiProvider).holidaysStream();
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(focusedMonthProvider.notifier).update(_focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: l10n.attendance_title,
        rightIcon: Consumer(
          builder: (context, ref, _) {
            final dash = ref.watch(dashboardProvider).value;
            final isRestricted =
                dash?.restrictedFeatures.contains('attendance') ?? false;
            final showScan = !isRestricted && (dash?.allowQrScan ?? false);

            final logsOpt = ref.watch(attendanceLogsProvider).value;
            final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
            final todayLog = logsOpt?.firstWhere(
              (l) => l.date == todayStr,
              orElse: () => const AttendanceRecord(
                id: 0,
                studentName: '',
                date: '',
                isPresent: false,
                isManual: false,
              ),
            );

            final isHoliday = dash?.isHoliday == true || dash?.attendanceStatus == 'Holiday';

            final isPresentOrLateFromDash = dash?.attendanceStatus == 'Present' ||
                dash?.attendanceStatus == 'Arrived Late' ||
                (dash?.markedAttendanceToday == true);

            final isPresentOrLateFromLogs = todayLog != null &&
                todayLog.id != 0 &&
                (todayLog.isPresent || todayLog.lateMark);

            final isAbsentFromLogs = todayLog != null &&
                todayLog.id != 0 &&
                !todayLog.isPresent &&
                !todayLog.lateMark;

            final isAbsent = !isHoliday &&
                (dash?.attendanceStatus == 'Absent' || isAbsentFromLogs);

            final isPresentOrLate = !isHoliday &&
                !isAbsent &&
                (isPresentOrLateFromDash || isPresentOrLateFromLogs);

            final isCheckedOut = todayLog != null &&
                todayLog.timeOut != null &&
                todayLog.timeOut!.isNotEmpty &&
                todayLog.timeOut != '00:00:00';

            final showCheckoutButton = isPresentOrLate && !isCheckedOut;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHoliday)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dash?.holidayTitle ?? 'Holiday',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (showCheckoutButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _isCheckingOut
                            ? null
                            : () async {
                                setState(() {
                                  _isCheckingOut = true;
                                });
                                try {
                                  await ref
                                      .read(studentApiProvider)
                                      .checkoutAttendance();
                                  
                                  // Clear the local cache for the current month so it re-fetches
                                  final focused = ref.read(focusedMonthProvider);
                                  await ref.read(localCacheServiceProvider).clearCache('attendanceLogs_${focused.year}_${focused.month}');
                                  ref.invalidate(attendanceLogsProvider);

                                  // Stop active study session if running
                                  final studyNotifier = ref.read(
                                    studySessionProvider.notifier,
                                  );
                                  final studyState = ref.read(
                                    studySessionProvider,
                                  );
                                  if (studyState.status ==
                                          StudySessionStatus.active ||
                                      studyState.status ==
                                          StudySessionStatus.starting) {
                                    await studyNotifier.stopSession();
                                  }

                                  if (context.mounted) {
                                    AppSnackbar.show(
                                      context,
                                      message: l10n.attendance_checkout_success,
                                      type: AppSnackbarType.success,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppSnackbar.show(
                                      context,
                                      message: e.toString(),
                                      type: AppSnackbarType.error,
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isCheckingOut = false;
                                    });
                                  }
                                }
                              },
                        icon: _isCheckingOut
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout, size: 18),
                        label: Text(
                          _isCheckingOut
                              ? l10n.attendance_wait
                              : l10n.attendance_check_out,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (showScan)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        onPressed: () => context.push('/attendance/scan'),
                      ),
                    ),
                ],
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
                // Clear local Hive cache so the stream always fetches fresh data
                final cache = ref.read(localCacheServiceProvider);
                await cache.invalidatePattern('attendanceLogs');
                await cache.clearCache('holidays');
                await cache.clearCache('dashboard');
                ref.invalidate(attendanceLogsProvider);
                ref.invalidate(holidaysProvider);
                ref.invalidate(dashboardProvider);
              },
              child: AsyncPane(
                value: ref.watch(attendanceLogsProvider),
                builder: (logs) {
                  final holidaysAsync = ref.watch(holidaysProvider);
                  final holidays = holidaysAsync.value ?? [];

                  final currentMonthLogs = logs.where((r) {
                    try {
                      final date = DateTime.parse(r.date);
                      return date.month == _focusedDay.month &&
                          date.year == _focusedDay.year;
                    } catch (_) {
                      return false;
                    }
                  }).toList();

                  final daysPresent = currentMonthLogs
                      .where((r) => r.isPresent)
                      .length;
                  final daysAbsent = currentMonthLogs
                      .where((r) => !r.isPresent && r.method != 'PENDING')
                      .length;
                  final totalLateMarks = currentMonthLogs
                      .where((r) => r.lateMark)
                      .length;

                  final studySessions =
                      ref.watch(studyHistoryProvider).value ?? [];
                  int monthlyStudyMinutes = 0;
                  int dailyStudyMinutes = 0;

                  for (final session in studySessions) {
                    try {
                      final start = DateTime.parse(session.startTime).toLocal();
                      if (start.month == _focusedDay.month &&
                          start.year == _focusedDay.year) {
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

                  // Build maps for quick lookup
                  final logMap = <String, AttendanceRecord>{};
                  for (final log in logs) {
                    logMap[log.date] = log;
                  }
                  final holidayMap = <String, HolidayRecord>{};
                  for (final h in holidays) {
                    holidayMap[h.date] = h;
                  }

                  final selectedDateString = DateFormat(
                    'yyyy-MM-dd',
                  ).format(_selectedDay ?? DateTime.now());
                  final selectedLog = logMap[selectedDateString];
                  final selectedHoliday = holidayMap[selectedDateString];

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkAppBarBg
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: _buildCalendar(logMap, holidayMap),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSelectedDayInfo(
                            selectedLog,
                            selectedHoliday,
                            dailyStudyH,
                            dailyStudyM,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildMonthlyStudyCard(
                            monthlyStudyH,
                            monthlyStudyM,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatsGrid(
                          daysPresent,
                          daysAbsent,
                          totalLateMarks,
                        ),
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

  Widget _buildCalendar(
    Map<String, AttendanceRecord> logMap,
    Map<String, HolidayRecord> holidayMap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          setState(() {
            _focusedDay = focusedDay;
          });
          ref.read(focusedMonthProvider.notifier).update(focusedDay);
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: textColor, size: 20),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: textColor,
            size: 20,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: 4),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _buildCell(day, logMap, holidayMap, isSelected: false),
          selectedBuilder: (context, day, focusedDay) =>
              _buildCell(day, logMap, holidayMap, isSelected: true),
          todayBuilder: (context, day, focusedDay) => _buildCell(
            day,
            logMap,
            holidayMap,
            isSelected: isSameDay(day, _selectedDay),
            isToday: true,
          ),
          outsideBuilder: (context, day, focusedDay) => const SizedBox(),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    DateTime day,
    Map<String, AttendanceRecord> logMap,
    Map<String, HolidayRecord> holidayMap, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    final log = logMap[dateString];
    final holiday = holidayMap[dateString];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color? bgColor;
    Color? textColor = theme.textTheme.bodyLarge?.color;
    Border? border;

    if (holiday != null) {
      bgColor = isDark
          ? Colors.purple.shade900.withValues(alpha: 0.3)
          : Colors.purple.shade50;
      textColor = isDark ? Colors.purple.shade200 : Colors.purple.shade800;
    } else if (log != null) {
      if (log.isPresent) {
        if (log.lateMark) {
          bgColor = isDark
              ? Colors.orange.shade900.withValues(alpha: 0.3)
              : Colors.orange.shade50;
          textColor = isDark ? Colors.orange.shade200 : Colors.orange.shade800;
        } else {
          bgColor = isDark
              ? Colors.green.shade900.withValues(alpha: 0.3)
              : Colors.green.shade50;
          textColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
        }
      } else if (log.method == 'PENDING') {
        bgColor = isDark
            ? Colors.yellow.shade900.withValues(alpha: 0.3)
            : Colors.yellow.shade50;
        textColor = isDark ? Colors.yellow.shade200 : Colors.yellow.shade800;
      } else {
        bgColor = isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50;
        textColor = isDark ? Colors.red.shade200 : Colors.red.shade800;
      }
    }

    if (isSelected) {
      border = Border.all(color: theme.colorScheme.primary, width: 1.5);
      bgColor ??= isDark
          ? AppColors.darkAppBarBg
          : theme.colorScheme.primary.withValues(alpha: 0.3);
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
                  label: AppLocalizations.of(context)!.attendance_days_present,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.person_off,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.shade50,
                  value: daysAbsent.toString(),
                  label: AppLocalizations.of(context)!.attendance_days_absent,
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
                  label: AppLocalizations.of(context)!.attendance_late_marks,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStudyCard(int hours, int minutes) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer,
              color: theme.textTheme.bodyLarge?.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${hours}h ${minutes}m',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.attendance_monthly_study,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo(
    AttendanceRecord? log,
    HolidayRecord? holiday,
    int studyH,
    int studyM,
  ) {
    String checkIn = '--:--';
    String checkOut = '--:--';

    if (log != null && log.isPresent) {
      if (log.timeIn != null) {
        try {
          final parts = log.timeIn!.split(':');
          if (parts.length >= 2) {
            final time = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
            final now = DateTime.now();
            final dt = DateTime(
              now.year,
              now.month,
              now.day,
              time.hour,
              time.minute,
            );
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
            final time = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
            final now = DateTime.now();
            final dt = DateTime(
              now.year,
              now.month,
              now.day,
              time.hour,
              time.minute,
            );
            checkOut = DateFormat('hh:mm a').format(dt);
          }
        } catch (_) {
          checkOut = log.timeOut!;
        }
      }
    }

    final theme = Theme.of(context);

    if (holiday != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [
                    Colors.purple.shade900.withValues(alpha: 0.5),
                    Colors.purple.shade800.withValues(alpha: 0.5),
                  ]
                : [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.purple.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              color: theme.brightness == Brightness.dark
                  ? Colors.purple.shade200
                  : Colors.purple,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              holiday.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: theme.brightness == Brightness.dark
                    ? Colors.purple.shade100
                    : Colors.purple.shade900,
              ),
            ),
            if (holiday.description != null &&
                holiday.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                holiday.description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.brightness == Brightness.dark
                      ? Colors.purple.shade200
                      : Colors.purple.shade800,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (log != null && !log.isPresent && log.method != 'PENDING') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [
                    Colors.red.shade900.withValues(alpha: 0.5),
                    Colors.red.shade800.withValues(alpha: 0.5),
                  ]
                : [Colors.red.shade50, Colors.red.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              color: theme.brightness == Brightness.dark
                  ? Colors.red.shade200
                  : Colors.red,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Absent',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: theme.brightness == Brightness.dark
                    ? Colors.red.shade100
                    : Colors.red.shade900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${studyH}h ${studyM}m',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.attendance_today_study,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
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
                      border: Border.all(color: theme.dividerColor, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.attendance_check_in,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.call_received,
                              size: 12,
                              color: Colors.green.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          checkIn,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.bodyLarge?.color,
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
                      border: Border.all(color: theme.dividerColor, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.attendance_check_out_lbl,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.call_made,
                              size: 12,
                              color: Colors.red.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          checkOut,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.bodyLarge?.color,
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
