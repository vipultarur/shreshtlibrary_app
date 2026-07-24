import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/features/study/providers/study_session_provider.dart';
import 'package:shreshtlibrary/features/attendance/attendance_screen.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';
import 'package:shreshtlibrary/common/widgets/premium_buy_container.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedHistoryDate = DateTime.now();
  String _chartViewMode = 'Week'; // 'Week' or 'Month'
  final PageController _pageController = PageController(initialPage: 10000);
  bool _isCheckingOut = false;

  Future<void> _handleCheckout() async {
    if (_isCheckingOut) return;
    setState(() {
      _isCheckingOut = true;
    });
    try {
      await ref.read(studentApiProvider).checkoutAttendance();
      final cache = ref.read(localCacheServiceProvider);
      await cache.invalidatePattern('attendanceLogs');
      await cache.clearCache('dashboard');
      ref.invalidate(attendanceLogsProvider);
      ref.invalidate(dashboardProvider);

      final studyNotifier = ref.read(studySessionProvider.notifier);
      final studyState = ref.read(studySessionProvider);
      if (studyState.status == StudySessionStatus.active ||
          studyState.status == StudySessionStatus.starting) {
        await studyNotifier.stopSession();
      }

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
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
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTabButton(
    String mode,
    String label,
    bool isDark,
    ThemeData theme,
  ) {
    final isSelected = _chartViewMode == mode;
    return GestureDetector(
      onTap: () {
        if (_chartViewMode != mode) {
          setState(() {
            _chartViewMode = mode;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(10000);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Clear local Hive cache entries so network always fetches fresh data
    final cache = ref.read(localCacheServiceProvider);
    await cache.clearCache('studySessionHistory');
    await cache.clearCache('leaderboard_month');
    await cache.clearCache('leaderboard_week');
    await cache.clearCache('dashboard');
    ref.invalidate(studyHistoryProvider);
    ref.invalidate(dashboardProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: _buildHeader(isDark, theme),
          ),
          Container(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.study_tracker),
                    Tab(text: l10n.study_history),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _buildTrackerTab(),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildHistoryTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final dash = ref.watch(dashboardProvider).value;
    final logsAsync = ref.watch(attendanceLogsProvider);
    final logsOpt = logsAsync.value;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayLog = logsOpt?.firstWhere(
      (l) => l.date == todayStr,
      orElse: () => AttendanceRecord(
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.study_area,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          if (showCheckoutButton)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _isCheckingOut ? null : _handleCheckout,
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
        ],
      ),
    );
  }

  Widget _buildTrackerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _buildActiveSessionView(),
        const SizedBox(height: 16),
        _buildStudyChart(),
      ],
    );
  }

  Widget _buildStudyChart() {
    final historyAsync = ref.watch(studyHistoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.study_analytics,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabButton(
                      'Week',
                      l10n.study_analytics_week,
                      isDark,
                      theme,
                    ),
                    _buildTabButton(
                      'Month',
                      l10n.study_analytics_month,
                      isDark,
                      theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            data: (history) {
              return SizedBox(
                height:
                    425, // Adjusted height to fit chart + summary cards and prevent overflow
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return _buildAnalyticsPage(
                      history,
                      index - 10000,
                      _chartViewMode,
                    );
                  },
                ),
              );
            },
            loading: () => Container(
              height: 425,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 16),
              child: Shimmer.fromColors(
                baseColor: theme.brightness == Brightness.dark
                    ? Colors.white10
                    : Colors.black12,
                highlightColor: theme.brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.white24,
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (_, __) => SizedBox(
              height: 425,
              child: Center(child: Text(l10n.study_failed_chart)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPage(
    List<StudySession> history,
    int offset,
    String mode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    List<double> totals;
    DateTime startOfRange;
    int numBars;
    String dateRangeLabel;

    if (mode == 'Week') {
      final monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      startOfRange = monday.add(Duration(days: offset * 7));
      final endOfWeek = startOfRange.add(const Duration(days: 6));
      dateRangeLabel =
          '${DateFormat('d MMM').format(startOfRange)} – ${DateFormat('d MMM yyyy').format(endOfWeek)}';

      numBars = 7;
      totals = List.filled(numBars, 0.0);

      for (final session in history) {
        try {
          final start = DateTime.parse(session.startTime).toLocal();
          final sessionDate = DateTime(start.year, start.month, start.day);
          final diff = sessionDate.difference(startOfRange).inDays;

          if (diff >= 0 && diff < numBars) {
            totals[diff] += session.durationMinutes.toDouble();
          }
        } catch (_) {}
      }
    } else {
      final targetMonth = DateTime(now.year, now.month + offset, 1);
      final nextMonth = DateTime(now.year, now.month + offset + 1, 1);
      dateRangeLabel = DateFormat('MMMM yyyy').format(targetMonth);

      final daysInMonth = nextMonth.difference(targetMonth).inDays;
      numBars = (daysInMonth / 7.0).ceil();
      startOfRange = targetMonth;
      totals = List.filled(numBars, 0.0);

      for (final session in history) {
        try {
          final start = DateTime.parse(session.startTime).toLocal();
          if (start.year == targetMonth.year &&
              start.month == targetMonth.month) {
            int weekIndex = (start.day - 1) ~/ 7;
            if (weekIndex >= 0 && weekIndex < numBars) {
              totals[weekIndex] += session.durationMinutes.toDouble();
            }
          }
        } catch (_) {}
      }
    }

    double totalMinutes = totals.fold(0.0, (sum, val) => sum + val);
    double avgMinutes = numBars > 0 ? totalMinutes / numBars : 0.0;

    double maxDuration = totals.isEmpty
        ? 0
        : totals.reduce((a, b) => a > b ? a : b);
    int mostProductiveIndex = totals.indexOf(maxDuration);
    String mostProductiveLabel = '--';

    if (maxDuration > 0) {
      if (mode == 'Week') {
        const days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        if (mostProductiveIndex >= 0 && mostProductiveIndex < days.length) {
          mostProductiveLabel = days[mostProductiveIndex];
        }
      } else {
        mostProductiveLabel = 'Week ${mostProductiveIndex + 1}';
      }
    }

    if (maxDuration < 60) maxDuration = 60; // minimum 1 hr scale

    final totalH = totalMinutes ~/ 60;
    final totalM = (totalMinutes % 60).toInt();

    final avgH = avgMinutes ~/ 60;
    final avgM = (avgMinutes % 60).toInt();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Text(
                  dateRangeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (totalMinutes == 0)
                SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      l10n.study_no_data,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxDuration * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) =>
                              theme.colorScheme.surfaceContainerHighest,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String label;
                            if (mode == 'Week') {
                              final date = startOfRange.add(
                                Duration(days: group.x),
                              );
                              label = DateFormat('MMM dd').format(date);
                            } else {
                              label = 'Week ${group.x + 1}';
                            }
                            return BarTooltipItem(
                              '$label\n${rod.toY.toInt()} min',
                              TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= numBars)
                                return const SizedBox.shrink();

                              String label = '';
                              bool isCurrent = false;

                              if (mode == 'Week') {
                                const days = [
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S',
                                  'S',
                                ];
                                label = days[idx];
                                final date = startOfRange.add(
                                  Duration(days: idx),
                                );
                                isCurrent =
                                    date.year == now.year &&
                                    date.month == now.month &&
                                    date.day == now.day;
                              } else {
                                label = 'W${idx + 1}';
                                final targetMonth = DateTime(
                                  now.year,
                                  now.month + offset,
                                  1,
                                );
                                if (targetMonth.year == now.year &&
                                    targetMonth.month == now.month) {
                                  int currentWeekIndex = (now.day - 1) ~/ 7;
                                  isCurrent = idx == currentWeekIndex;
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCurrent
                                        ? theme.colorScheme.primary
                                        : Colors.grey,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxDuration / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      barGroups: List.generate(numBars, (index) {
                        bool isCurrent = false;
                        if (mode == 'Week') {
                          final date = startOfRange.add(Duration(days: index));
                          isCurrent =
                              date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;
                        } else {
                          final targetMonth = DateTime(
                            now.year,
                            now.month + offset,
                            1,
                          );
                          if (targetMonth.year == now.year &&
                              targetMonth.month == now.month) {
                            int currentWeekIndex = (now.day - 1) ~/ 7;
                            isCurrent = index == currentWeekIndex;
                          }
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: totals[index],
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                              width: mode == 'Month' ? 24 : 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: l10n.study_total_time,
                value: '${totalH}h ${totalM}m',
                icon: Icons.timer,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: mode == 'Week'
                    ? l10n.study_avg_daily
                    : l10n.study_avg_weekly,
                value: '${avgH}h ${avgM}m',
                icon: Icons.show_chart,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          title: l10n.study_most_productive,
          value: mostProductiveLabel,
          icon: Icons.star,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView() {
    final state = ref.watch(studySessionProvider);
    final notifier = ref.read(studySessionProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dash = ref.watch(dashboardProvider).value;
    final isExpired = dash?.membershipStatus == 'EXPIRED';

    if (isExpired) {
      return const PremiumBuyContainer();
    }

    final logsAsync = ref.watch(attendanceLogsProvider);
    if (logsAsync.isLoading) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Shimmer.fromColors(
          baseColor: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          highlightColor: theme.brightness == Brightness.dark
              ? Colors.white24
              : Colors.white24,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      );
    }

    final logsOpt = logsAsync.value;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayLog = logsOpt?.firstWhere(
      (l) => l.date == todayStr,
      orElse: () => AttendanceRecord(
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

    final canStartSession = isPresentOrLate && !isCheckedOut;

    if (!canStartSession &&
        state.status != StudySessionStatus.active &&
        state.status != StudySessionStatus.starting) {
      IconData iconData = Icons.location_off;
      String title = l10n.study_not_checked_in;
      String desc = l10n.study_not_checked_in_desc;
      Color iconColor = Colors.grey;

      if (isHoliday) {
        iconData = Icons.celebration;
        iconColor = Colors.purple;
        title = dash?.holidayTitle ?? 'Library Holiday';
        desc = dash?.holidayDescription ??
            'Today is a holiday. Study sessions cannot be started on holidays.';
      } else if (isAbsent) {
        iconData = Icons.person_off;
        iconColor = Colors.red;
        title = 'Marked Absent Today';
        desc =
            'Your attendance was marked as absent for today. Study sessions cannot be started.';
      } else if (isCheckedOut) {
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        title = 'Checked Out For Today';
        desc =
            'You have already checked out for today.';
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      );
    }

    if (state.status == StudySessionStatus.starting) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Shimmer.fromColors(
          baseColor: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          highlightColor: theme.brightness == Brightness.dark
              ? Colors.white24
              : Colors.white24,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      );
    }

    if (state.status == StudySessionStatus.idle ||
        state.status == StudySessionStatus.error) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.study_ready_focus,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.study_ready_focus_desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await notifier.startSession();
                      if (context.mounted) {
                        ref.invalidate(studyHistoryProvider);
                      }
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(
                      l10n.study_start_btn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isCheckingOut ? null : _handleCheckout,
                    icon: _isCheckingOut
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.logout, color: theme.colorScheme.primary),
                    label: Text(
                      _isCheckingOut
                          ? l10n.attendance_wait
                          : l10n.attendance_check_out,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Color primaryColor = theme.colorScheme.primary;
    bool isPaused = state.isPaused;

    double progressValue;
    Color progressColor;
    String centerText;

    if (!isPaused) {
      progressValue = (state.elapsed.inSeconds % 3600) / 3600.0;
      progressColor = primaryColor;
      centerText = _formatTime(state.elapsed.inSeconds);
    } else {
      progressValue = state.verificationRemaining / 60.0;
      progressColor = Colors.orange;
      centerText = _formatTime(state.verificationRemaining);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 16,
                  strokeCap: StrokeCap.round,
                  backgroundColor: progressColor.withValues(alpha: 0.1),
                  color: progressColor,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerText,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 44,
                          letterSpacing: -1,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (isPaused) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.study_paused,
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.pause_circle_outline,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.study_total_paused(_formatTime(state.pausedSeconds)),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.status == StudySessionStatus.stopping)
                const CircularProgressIndicator()
              else
                _buildControlButton(
                  icon: Icons.stop,
                  label: l10n.study_quit_btn,
                  color: Colors.redAccent,
                  onTap: () async {
                    await notifier.stopSession();
                    if (context.mounted) {
                      ref.invalidate(studyHistoryProvider);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(studyHistoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: IconTheme(
            data: IconThemeData(color: theme.textTheme.bodyLarge?.color),
            child: EasyDateTimeLine(
              initialDate: _selectedHistoryDate,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedHistoryDate = selectedDate;
                });
              },
              headerProps: EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                dateFormatter: const DateFormatter.fullDateDayAsStrMY(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                monthStyle: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              dayProps: EasyDayProps(
                height: 70,
                width: 60,
                dayStructure: DayStructure.dayNumDayStr,
                activeDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: theme.colorScheme.primary,
                  ),
                  dayNumStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  dayStrStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                inactiveDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.dividerColor),
                  ),
                  dayNumStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  dayStrStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                todayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  dayNumStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  dayStrStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: historyAsync.when(
            data: (history) {
              final filteredHistory = history.where((session) {
                try {
                  final start = DateTime.parse(session.startTime).toLocal();
                  return start.year == _selectedHistoryDate.year &&
                      start.month == _selectedHistoryDate.month &&
                      start.day == _selectedHistoryDate.day;
                } catch (_) {
                  return false;
                }
              }).toList();

              if (filteredHistory.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          l10n.study_history_sessions(history.length),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildEmptyState(
                      l10n.study_history_empty,
                      Icons.history_toggle_off,
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Center(
                      child: Text(
                        l10n.study_history_sessions(history.length),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredHistory.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (c, i) =>
                          _buildHistoryCard(filteredHistory[i]),
                    ),
                  ),
                ],
              );
            },
            loading: () =>
                ListView(children: const [_SkeletonBox(height: 100)]),
            error: (e, s) => ListView(
              children: [Center(child: Text(l10n.study_failed_history))],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(StudySession session) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = session.isActive;

    DateTime? startTime;
    try {
      startTime = DateTime.parse(session.startTime).toLocal();
    } catch (_) {}

    final dateStr = startTime != null
        ? DateFormat('MMM dd, yyyy').format(startTime)
        : l10n.study_unknown_date;
    final timeStr = startTime != null
        ? DateFormat('hh:mm a').format(startTime)
        : '--:--';

    final h = session.durationMinutes ~/ 60;
    final m = session.durationMinutes % 60;
    final durationStr = '${h > 0 ? '${h}h ' : ''}${m}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isActive ? Icons.play_arrow_rounded : Icons.check_circle,
              color: isActive ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.study_history_started_at(timeStr),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isActive ? 'Ongoing' : durationStr,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isActive ? 15 : 18,
                  color: isActive ? Colors.orange : theme.textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                isActive ? 'Active Now' : l10n.study_history_studied,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 54, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.study_history_empty_desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.white24,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
