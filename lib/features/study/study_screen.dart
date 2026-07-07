import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/features/study/providers/study_session_provider.dart';
import 'package:shreshtlibrary/features/attendance/attendance_screen.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedHistoryDate = DateTime.now();
  String _chartViewMode = 'Week'; // 'Week' or 'Month'
  final PageController _pageController = PageController(initialPage: 10000);
  int _currentPageOffset = 0;

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

  Future<void> _onRefresh() async {
    ref.invalidate(studyHistoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCBB9FF),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: _buildHeader(),
          ),
          Container(
            color: const Color(0xFFCBB9FF),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1EFFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF140C2C),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Tracker'),
                    Tab(text: 'History'),
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

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Study Area',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF140C2C),
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

  String _getDateRangeLabel() {
    final now = DateTime.now();
    if (_chartViewMode == 'Week') {
      final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final startOfWeek = monday.add(Duration(days: _currentPageOffset * 7));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('d MMM').format(startOfWeek)} – ${DateFormat('d MMM yyyy').format(endOfWeek)}';
    } else {
      final targetMonth = DateTime(now.year, now.month + _currentPageOffset, 1);
      return DateFormat('MMMM yyyy').format(targetMonth);
    }
  }

  Widget _buildStudyChart() {
    final historyAsync = ref.watch(studyHistoryProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF140C2C),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _chartViewMode,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF140C2C), size: 20),
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF140C2C),
                    ),
                    items: ['Week', 'Month'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _chartViewMode = newValue;
                          _currentPageOffset = 0;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(10000);
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            data: (history) {
              return SizedBox(
                height: 400, // Adjusted height to fit chart + summary cards
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageOffset = index - 10000;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildAnalyticsPage(history, index - 10000, _chartViewMode);
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 400, child: Center(child: CircularProgressIndicator(color: Color(0xFF8B7DF1)))),
            error: (_, __) => const SizedBox(height: 400, child: Center(child: Text('Failed to load chart'))),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPage(List<StudySession> history, int offset, String mode) {
    final now = DateTime.now();
    
    List<double> totals;
    DateTime startOfRange;
    int numBars;
    String dateRangeLabel;
    
    if (mode == 'Week') {
      final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      startOfRange = monday.add(Duration(days: offset * 7));
      final endOfWeek = startOfRange.add(const Duration(days: 6));
      dateRangeLabel = '${DateFormat('d MMM').format(startOfRange)} – ${DateFormat('d MMM yyyy').format(endOfWeek)}';
      
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
          if (start.year == targetMonth.year && start.month == targetMonth.month) {
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
    
    double maxDuration = totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);
    int mostProductiveIndex = totals.indexOf(maxDuration);
    String mostProductiveLabel = '--';
    
    if (maxDuration > 0) {
      if (mode == 'Week') {
        const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Center(
                child: Text(
                  dateRangeLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              if (totalMinutes == 0)
                const SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
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
                          getTooltipColor: (_) => const Color(0xFF140C2C),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String label;
                            if (mode == 'Week') {
                              final date = startOfRange.add(Duration(days: group.x));
                              label = DateFormat('MMM dd').format(date);
                            } else {
                              label = 'Week ${group.x + 1}';
                            }
                            return BarTooltipItem(
                              '$label\n${rod.toY.toInt()} min',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              if (idx < 0 || idx >= numBars) return const SizedBox.shrink();
                              
                              String label = '';
                              bool isCurrent = false;
                              
                              if (mode == 'Week') {
                                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                label = days[idx];
                                final date = startOfRange.add(Duration(days: idx));
                                isCurrent = date.year == now.year && date.month == now.month && date.day == now.day;
                              } else {
                                label = 'W${idx + 1}';
                                final targetMonth = DateTime(now.year, now.month + offset, 1);
                                if (targetMonth.year == now.year && targetMonth.month == now.month) {
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
                                    color: isCurrent ? const Color(0xFF8B7DF1) : Colors.grey,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                             isCurrent = date.year == now.year && date.month == now.month && date.day == now.day;
                         } else {
                             final targetMonth = DateTime(now.year, now.month + offset, 1);
                             if (targetMonth.year == now.year && targetMonth.month == now.month) {
                                 int currentWeekIndex = (now.day - 1) ~/ 7;
                                 isCurrent = index == currentWeekIndex;
                             }
                         }
                        
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: totals[index],
                              color: isCurrent ? const Color(0xFF8B7DF1) : const Color(0xFFCBB9FF),
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
                title: 'Total Time',
                value: '${totalH}h ${totalM}m',
                icon: Icons.timer,
                color: const Color(0xFF8B7DF1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: mode == 'Week' ? 'Avg Daily' : 'Avg Weekly',
                value: '${avgH}h ${avgM}m',
                icon: Icons.show_chart,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          title: 'Most Productive',
          value: mostProductiveLabel,
          icon: Icons.star,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF140C2C),
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
    
    final logsAsync = ref.watch(attendanceLogsProvider);
    if (logsAsync.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF8B7DF1))),
      );
    }
    
    final logsOpt = logsAsync.value;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayLog = logsOpt?.firstWhere(
        (l) => l.date == todayStr,
        orElse: () => AttendanceRecord(id: 0, studentName: '', date: '', isPresent: false, isManual: false));
        
    final isCheckedIn = todayLog != null && todayLog.isPresent && todayLog.timeIn != null;
    final isCheckedOut = todayLog != null && todayLog.timeOut != null;
    final canStartSession = isCheckedIn && !isCheckedOut;

    if (!canStartSession && state.status != StudySessionStatus.active && state.status != StudySessionStatus.starting) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
              decoration: const BoxDecoration(
                color: Color(0xFFF1EFFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'Not Checked In',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF140C2C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check in at the library to start an anti-distraction study session.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      );
    }

    if (state.status == StudySessionStatus.starting) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF8B7DF1))),
      );
    }

    if (state.status == StudySessionStatus.idle || state.status == StudySessionStatus.error) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
              decoration: const BoxDecoration(
                color: Color(0xFFF1EFFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer, size: 48, color: Color(0xFF8B7DF1)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ready to Focus?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF140C2C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start an anti-distraction study session. If you move your phone, tracking pauses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await notifier.startSession();
                  if (context.mounted) {
                    ref.invalidate(studyHistoryProvider);
                  }
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('Start New Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF140C2C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color primaryColor = const Color(0xFF8B7DF1);
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
        color: Colors.white,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 44,
                          letterSpacing: -1,
                          color: Color(0xFF140C2C),
                        ),
                      ),
                      if (isPaused) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PAUSED',
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
              const Icon(Icons.pause_circle_outline, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                'Total Paused: ${_formatTime(state.pausedSeconds)}',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
                  label: 'Quit',
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

  Widget _buildControlButton({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
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
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(studyHistoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: IconTheme(
            data: const IconThemeData(color: Color(0xFF140C2C)),
            child: EasyDateTimeLine(
              initialDate: _selectedHistoryDate,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedHistoryDate = selectedDate;
                });
              },
              headerProps: const EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                dateFormatter: DateFormatter.fullDateDayAsStrMY(),
                padding: EdgeInsets.symmetric(horizontal: 20),
                monthStyle: TextStyle(color: Color(0xFF140C2C), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              dayProps: EasyDayProps(
                height: 70,
                width: 60,
                dayStructure: DayStructure.dayNumDayStr,
                activeDayStyle: const DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Color(0xFF140C2C),
                  ),
                  dayNumStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  dayStrStyle: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                inactiveDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  dayNumStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                  dayStrStyle: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                todayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF140C2C), width: 1.5),
                  ),
                  dayNumStyle: const TextStyle(color: Color(0xFF140C2C), fontSize: 18, fontWeight: FontWeight.bold),
                  dayStrStyle: const TextStyle(color: Color(0xFF140C2C), fontSize: 11, fontWeight: FontWeight.bold),
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
                      child: Center(child: Text('Total sessions in memory: ${history.length}', style: const TextStyle(color: Colors.grey, fontSize: 12))),
                    ),
                    const SizedBox(height: 50),
                    _buildEmptyState('No Study Sessions on this date', Icons.history_toggle_off),
                  ],
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Center(child: Text('Total sessions in memory: ${history.length}', style: const TextStyle(color: Colors.grey, fontSize: 12))),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredHistory.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (c, i) => _buildHistoryCard(filteredHistory[i]),
                    ),
                  ),
                ],
              );
            },
            loading: () => ListView(children: const [_SkeletonBox(height: 100)]),
            error: (e, s) => ListView(children: const [Center(child: Text('Failed to load history'))]),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(StudySession session) {
    DateTime? startTime;
    try { startTime = DateTime.parse(session.startTime).toLocal(); } catch (_) {}
    
    final dateStr = startTime != null ? DateFormat('MMM dd, yyyy').format(startTime) : 'Unknown Date';
    final timeStr = startTime != null ? DateFormat('hh:mm a').format(startTime) : '--:--';
    
    final h = session.durationMinutes ~/ 60;
    final m = session.durationMinutes % 60;
    final durationStr = '${h > 0 ? '${h}h ' : ''}${m}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF140C2C))),
                const SizedBox(height: 2),
                Text('Started at $timeStr', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(durationStr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF140C2C))),
              const Text('Studied', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFCBB9FF).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 54, color: const Color(0xFFCBB9FF)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "Take a break, or start a new session!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black38),
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
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.white24,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
