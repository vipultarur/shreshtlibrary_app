import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:lottie/lottie.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/notification_service.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/features/study/widgets/control_button.dart';

final currentSessionProvider = FutureProvider.autoDispose<StudySession?>((ref) {
  return ref.watch(studentApiProvider).currentStudySession();
});

final studyHistoryProvider = FutureProvider.autoDispose<List<StudySession>>((ref) {
  return ref.watch(studentApiProvider).studySessionHistory();
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(studentApiProvider).leaderboard();
});

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  StudySession? _session;
  bool _busy = false;

  StreamSubscription? _accelSub;
  Timer? _ticker;

  String _status = 'loading'; // loading, none, starting, active, paused
  DateTime? _lastMotionTime;
  
  StreamSubscription? _actionSub;

  int _effectiveSeconds = 0;
  int _pausedSeconds = 0;

  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = ref.read(notificationServiceProvider);
    _loadSession();
    
    // Listen for notification actions
    _actionSub = _notificationService.actionStream.listen((action) {
      if (action == 'stop_session') {
        _endSession();
      }
    });
  }

  @override
  void dispose() {
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
        setState(() {
          _status = 'none';
        });
      }
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Failed to load session: $e');
      setState(() => _status = 'none');
    }
  }

  DateTime? _lastTickTime;

  void _startTracking() {
    _accelSub?.cancel();
    _ticker?.cancel();

    _lastMotionTime = DateTime.now(); // force initial wait
    _lastTickTime = DateTime.now();

    _accelSub = userAccelerometerEventStream().listen((event) {
      final magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      if (magnitude > 1.5) {
        // Significant motion detected
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
          ref.read(notificationServiceProvider).startStudySessionNotification();
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
          ref.read(notificationServiceProvider).startStudySessionNotification();
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
    } catch (_) {
      // Ignore background errors
    }
  }

  Future<void> _endSession() async {
    setState(() => _busy = true);
    try {
      _accelSub?.cancel();
      _ticker?.cancel();
      ref.read(notificationServiceProvider).stopStudySessionNotification();
      
      final durMin = _effectiveSeconds ~/ 60;
      final pauMin = _pausedSeconds ~/ 60;
      
      await ref.read(studentApiProvider).endStudySession(durMin, pauMin);
      
      if (!mounted) return;
      showSnack(context, 'Study session completed!');
      setState(() {
        _session = null;
        _status = 'none';
        _effectiveSeconds = 0;
        _pausedSeconds = 0;
      });
      ref.invalidate(currentSessionProvider);
      ref.invalidate(studyHistoryProvider);
      ref.invalidate(leaderboardProvider);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      showSnack(context, e.message);
      _startTracking(); // Resume if failed
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startNewSession() async {
    setState(() => _busy = true);
    try {
      final session = await ref.read(studentApiProvider).startStudySession();
      if (!mounted) return;
      setState(() {
        _session = session;
        _status = session.status;
        _effectiveSeconds = session.durationMinutes * 60;
        _pausedSeconds = session.pausedMinutes * 60;
      });
      _startTracking();
      ref.invalidate(currentSessionProvider);
      ref.invalidate(studyHistoryProvider);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Failed to start session: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: PageScaffold(
        title: 'Study Area',
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Tracker'),
                Tab(text: 'Leaderboard'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTrackerTab(),
                  _buildLeaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerTab() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentSessionProvider);
        ref.invalidate(studyHistoryProvider);
        await _loadSession();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            _buildActiveSessionView(),
            const Divider(height: 1, thickness: 1),
            _buildHistoryView(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return AsyncPane(
      value: ref.watch(leaderboardProvider),
      builder: (leaderboard) {
        if (leaderboard.isEmpty) {
          return const Center(child: Text('No data for this month.'));
        }
        return Column(
          children: [
            SizedBox(
              height: 120,
              child: Lottie.network(
                'https://lottie.host/e2ba1b9f-6e82-4161-aa8f-28562725ad50/oQ5sF9k69L.json', // generic trophy
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Top Scholars',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final theme = Theme.of(context);
            
            // Parse badge color from hex
            Color badgeColor = Colors.grey;
            try {
              final hex = entry.levelInfo.badgeColor.replaceAll('#', '');
              badgeColor = Color(int.parse('FF$hex', radix: 16));
            } catch (_) {}

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: index < 3 ? badgeColor.withValues(alpha: 0.5) : Colors.transparent,
                  width: index < 3 ? 2 : 0,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: badgeColor.withValues(alpha: 0.2),
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  entry.student.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  entry.levelInfo.title,
                  style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      entry.hoursFormatted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'studied',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ),
        ],
        );
      },
    );
  }

  Widget _buildActiveSessionView() {
    if (_status == 'loading') {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_status == 'none') {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_off_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No active study session.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _busy ? null : _startNewSession,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start New Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Color primaryColor = Theme.of(context).colorScheme.primary;
    bool isPaused = _status == 'paused' || _status == 'starting';
    IconData playPauseIcon = isPaused ? Icons.play_arrow : Icons.pause;
    String playPauseLabel = isPaused ? 'Resume' : 'Pause';

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
      progressColor = Colors.amber; // Yellow progress
      centerText = _formatTime(reverseCountdown);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        // Timer Circle
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 20,
                  strokeCap: StrokeCap.round,
                  backgroundColor: progressColor.withValues(alpha: 0.15),
                  color: progressColor,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerText,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 64,
                          letterSpacing: 2,
                        ),
                      ),
                      if (isPaused) ...[
                        const SizedBox(height: 8),
                        Text(
                          _status == 'starting' ? 'STARTING...' : 'PAUSED',
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        // Extra application elements
        Text(
          'Paused Time: ${_formatTime(_pausedSeconds)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 64),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ControlButton(
              icon: playPauseIcon,
              label: playPauseLabel,
              onTap: () {
                if (_status == 'active') {
                  _updateBackendStatus('paused');
                  setState(() => _status = 'paused');
                } else if (_status == 'paused') {
                  _lastMotionTime = null; // Prevent immediate re-pause
                  _updateBackendStatus('active');
                  setState(() => _status = 'active');
                }
              },
            ),
            const SizedBox(width: 48), // Adjusted spacing to match image
            ControlButton(
              icon: Icons.stop,
              label: 'Quit',
              onTap: _busy ? null : _endSession,
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHistoryView() {
    return AsyncPane(
      value: ref.watch(studyHistoryProvider),
      builder: (history) {
        if (history.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No study history found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Study History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = history[index];
                  // Format the start time
                  DateTime? startTime;
                  try {
                    startTime = DateTime.parse(session.startTime);
                  } catch (_) {}
                  
                  final dateStr = startTime != null ? '${startTime.day}/${startTime.month}/${startTime.year}' : 'Unknown Date';
                  final timeStr = startTime != null ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}' : '--:--';
                  
                  final h = session.durationMinutes ~/ 60;
                  final m = session.durationMinutes % 60;
                  final durationStr = '${h > 0 ? '${h}h ' : ''}${m}m';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Icon(Icons.history, color: Colors.indigo.shade400),
                      ),
                      title: Text(
                        dateStr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Started at $timeStr'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            durationStr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const Text(
                            'Studied',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
