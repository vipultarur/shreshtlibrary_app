import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';


final studyHistoryProvider = FutureProvider.autoDispose<List<StudySession>>((ref) {
  return ref.watch(studentApiProvider).studySessionHistory();
});


class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  StudySession? _session;
  bool _busy = false;
  String _status = 'loading'; // loading, none, starting, active, paused
  
  StreamSubscription? _accelSub;
  Timer? _ticker;
  StreamSubscription? _actionSub;
  
  DateTime? _lastMotionTime;
  DateTime? _lastTickTime;
  
  int _effectiveSeconds = 0;
  int _pausedSeconds = 0;

  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notificationService = ref.read(notificationServiceProvider);
    
    _loadSession();

    _actionSub = _notificationService.actionStream.listen((action) {
      if (action == 'stop_session') {
        _endSession();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accelSub?.cancel();
    _ticker?.cancel();
    _actionSub?.cancel();
    _notificationService.stopStudySessionNotification();
    super.dispose();
  }

  Future<void> _loadSession() async {
    try {
      final session = await ref.read(studentApiProvider).currentStudySession();
      if (!mounted) return;
      if (session != null) {
        setState(() {
          _session = session;
          _status = session.status;
          _effectiveSeconds = session.durationMinutes * 60;
          _pausedSeconds = session.pausedMinutes * 60;
        });
        _startTracking();
      } else {
        setState(() => _status = 'none');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'none');
    }
  }

  void _startTracking() {
    _accelSub?.cancel();
    _ticker?.cancel();

    _lastMotionTime = DateTime.now();
    _lastTickTime = DateTime.now();

    _accelSub = userAccelerometerEventStream().listen((event) {
      final magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      if (magnitude > 1.5) {
        _lastMotionTime = DateTime.now();
      }
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (_session == null || _status == 'none') return;

    final now = DateTime.now();
    final deltaSeconds = _lastTickTime != null ? now.difference(_lastTickTime!).inSeconds : 1;
    _lastTickTime = now;
    
    final secondsSinceMotion = _lastMotionTime != null ? now.difference(_lastMotionTime!).inSeconds : 60;

    setState(() {
      if (_status == 'starting') {
        if (secondsSinceMotion >= 60) {
          _updateBackendStatus('active');
          _status = 'active';
          _notificationService.startStudySessionNotification();
        }
      } else if (_status == 'active') {
        _effectiveSeconds += deltaSeconds;
        if (secondsSinceMotion < 2) {
          _updateBackendStatus('paused');
          _status = 'paused';
        }
      } else if (_status == 'paused') {
        _pausedSeconds += deltaSeconds;
        if (secondsSinceMotion >= 60) {
          _updateBackendStatus('active');
          _status = 'active';
          _notificationService.startStudySessionNotification();
        }
      }
    });
  }

  Future<void> _updateBackendStatus(String newStatus) async {
    try {
      await ref.read(studentApiProvider).updateStudySessionStatus(
        newStatus,
        durationMinutes: _effectiveSeconds ~/ 60,
        pausedMinutes: _pausedSeconds ~/ 60,
      );
    } catch (_) {}
  }

  Future<void> _startNewSession() async {
    setState(() => _busy = true);
    try {
      final logs = await ref.read(studentApiProvider).attendanceLogs();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayLog = logs.firstWhere(
        (l) => l.date == todayStr, 
        orElse: () => const AttendanceRecord(id: 0, studentName: '', date: '', isPresent: false, isManual: false)
      );
      
      if (todayLog.timeOut != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot start a new session after checking out.')));
        return;
      }

      final session = await ref.read(studentApiProvider).startStudySession();
      if (!mounted) return;
      setState(() {
        _session = session;
        _status = 'starting';
        _effectiveSeconds = session.durationMinutes * 60;
        _pausedSeconds = session.pausedMinutes * 60;
      });
      _startTracking();
      ref.invalidate(studyHistoryProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start session: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _endSession() async {
    setState(() => _busy = true);
    try {
      _accelSub?.cancel();
      _ticker?.cancel();
      _notificationService.stopStudySessionNotification();
      
      final durMin = _effectiveSeconds ~/ 60;
      final pauMin = _pausedSeconds ~/ 60;
      
      await ref.read(studentApiProvider).endStudySession(durMin, pauMin);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Study session completed!')));
      setState(() {
        _session = null;
        _status = 'none';
        _effectiveSeconds = 0;
        _pausedSeconds = 0;
      });
      ref.invalidate(studyHistoryProvider);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to end session.')));
      _startTracking();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }


  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _onRefresh() async {

    ref.invalidate(studyHistoryProvider);

    await _loadSession();
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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF140C2C),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _buildHistoryTab(),
                  ),
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
      ],
    );
  }


  Widget _buildActiveSessionView() {
    if (_status == 'loading') {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF8B7DF1))),
      );
    }

    if (_status == 'none') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(32),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer, size: 64, color: Color(0xFF8B7DF1)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ready to Focus?',
              style: TextStyle(
                fontSize: 22,
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _startNewSession,
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
    bool isPaused = _status == 'paused' || _status == 'starting';

    final now = DateTime.now();
    final int secondsSinceMotion = _lastMotionTime != null ? now.difference(_lastMotionTime!).inSeconds : 60;
    final int reverseCountdown = max(0, 60 - secondsSinceMotion);

    double progressValue;
    Color progressColor;
    String centerText;

    if (!isPaused) {
      progressValue = (_effectiveSeconds % 3600) / 3600.0;
      progressColor = primaryColor;
      centerText = _formatTime(_effectiveSeconds);
    } else {
      progressValue = reverseCountdown / 60.0;
      progressColor = Colors.orange; // Amber/Yellow equivalent
      centerText = _formatTime(reverseCountdown);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 16),
          SizedBox(
            width: 240,
            height: 240,
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
                          fontSize: 56,
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
                            _status == 'starting' ? 'STARTING' : 'PAUSED',
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
                'Total Paused: ${_formatTime(_pausedSeconds)}',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.stop,
                label: 'Quit',
                color: Colors.redAccent,
                onTap: _busy ? null : _endSession,
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: historyAsync.when(
        data: (history) {
          if (history.isEmpty) return _buildEmptyState('No Study Sessions', Icons.history_toggle_off);
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (c, i) => _buildHistoryCard(history[i]),
          );
        },
        loading: () => const _SkeletonBox(height: 100),
        error: (e, s) => const Center(child: Text('Failed to load history')),
      ),
    );
  }

  Widget _buildHistoryCard(StudySession session) {
    DateTime? startTime;
    try { startTime = DateTime.parse(session.startTime); } catch (_) {}
    
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF140C2C))),
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
