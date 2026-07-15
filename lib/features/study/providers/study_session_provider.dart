import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

enum StudySessionStatus {
  idle,
  starting,
  active,
  stopping,
  error
}

class StudySessionState {
  final StudySessionStatus status;
  final DateTime? startTime;
  final Duration elapsed;
  final String? errorMessage;
  final StudySession? currentSession;
  final bool isPaused;
  final int verificationRemaining;
  final int pausedSeconds;

  StudySessionState({
    required this.status,
    this.startTime,
    this.elapsed = Duration.zero,
    this.errorMessage,
    this.currentSession,
    this.isPaused = false,
    this.verificationRemaining = 0,
    this.pausedSeconds = 0,
  });

  StudySessionState copyWith({
    StudySessionStatus? status,
    DateTime? startTime,
    Duration? elapsed,
    String? errorMessage,
    StudySession? currentSession,
    bool? isPaused,
    int? verificationRemaining,
    int? pausedSeconds,
  }) {
    return StudySessionState(
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSession: currentSession ?? this.currentSession,
      isPaused: isPaused ?? this.isPaused,
      verificationRemaining: verificationRemaining ?? this.verificationRemaining,
      pausedSeconds: pausedSeconds ?? this.pausedSeconds,
    );
  }
}

class StudySessionNotifier extends Notifier<StudySessionState> {
  StreamSubscription<Map<String, dynamic>?>? _updateSub;
  
  @override
  StudySessionState build() {
    _init();
    ref.onDispose(() {
      _updateSub?.cancel();
    });
    return StudySessionState(status: StudySessionStatus.idle);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      _setupServiceListener();
      final api = ref.read(studentApiProvider);
      final session = await api.getCurrentSession();
      
      if (session != null && session.isActive) {
        final startTime = DateTime.parse(session.startTime).toLocal();
        await prefs.setString('study_session_start', startTime.toIso8601String());
        await prefs.setInt('study_session_id', session.id);
        
        state = state.copyWith(
          status: StudySessionStatus.active,
          startTime: startTime,
          currentSession: session,
          elapsed: DateTime.now().difference(startTime),
        );
        ref.read(studySessionServiceProvider).startService();
      } else {
        // Backend says no active session, clear local state if any exists
        await prefs.remove('study_session_start');
        await prefs.remove('study_session_id');
        await ref.read(studySessionServiceProvider).stopService();
        state = state.copyWith(status: StudySessionStatus.idle, startTime: null, currentSession: null);
      }
    } catch (e) {
      // Fallback to local storage if API call fails
      final startTimeStr = prefs.getString('study_session_start');
      if (startTimeStr != null) {
        final startTime = DateTime.parse(startTimeStr);
        state = state.copyWith(
          status: StudySessionStatus.active,
          startTime: startTime,
          elapsed: DateTime.now().difference(startTime),
        );
        ref.read(studySessionServiceProvider).startService();
      }
    }
  }

  void _setupServiceListener() {
    _updateSub?.cancel();
    _updateSub = FlutterBackgroundService().on('update').listen((event) {
      if (event != null) {
        final int elapsedSecs = (event['elapsed'] as num?)?.toInt() ?? 0;
        final bool isPaused = (event['is_paused'] as bool?) ?? false;
        final int verificationRemaining = (event['remaining_verification_seconds'] as num?)?.toInt() ?? 0;
        final int pSeconds = (event['paused_seconds'] as num?)?.toInt() ?? 0;
        
        state = state.copyWith(
          elapsed: Duration(seconds: elapsedSecs),
          isPaused: isPaused,
          verificationRemaining: verificationRemaining,
          pausedSeconds: pSeconds,
        );
      }
    });
  }

  Future<void> startSession() async {
    if (state.status == StudySessionStatus.starting || state.status == StudySessionStatus.active) {
      return;
    }
    
    state = state.copyWith(status: StudySessionStatus.starting, errorMessage: null);

    try {
      final api = ref.read(studentApiProvider);
      final session = await api.startStudySession();
      
      final prefs = await SharedPreferences.getInstance();
      final startTime = DateTime.parse(session.startTime).toLocal();
      
      await prefs.setString('study_session_start', startTime.toIso8601String());
      await prefs.setInt('study_session_id', session.id);
      
      state = state.copyWith(
        status: StudySessionStatus.active,
        startTime: startTime,
        currentSession: session,
        elapsed: Duration.zero,
        isPaused: false,
      );
      
      await ref.read(studySessionServiceProvider).startService();
      
    } catch (e) {
      state = state.copyWith(
        status: StudySessionStatus.error,
        errorMessage: 'Failed to start session. Please try again.',
      );
      Future.delayed(const Duration(seconds: 3), () {
        try {
          if (state.status == StudySessionStatus.error) {
            state = state.copyWith(status: StudySessionStatus.idle, errorMessage: null);
          }
        } catch (_) {}
      });
    }
  }

  Future<void> stopSession() async {
    if (state.status == StudySessionStatus.stopping || state.status == StudySessionStatus.idle) {
      return;
    }

    state = state.copyWith(status: StudySessionStatus.stopping);

    try {
      final api = ref.read(studentApiProvider);
      final durationMinutes = state.elapsed.inMinutes;
      final prefs = await SharedPreferences.getInstance();
      
      final pausedSeconds = prefs.getInt('paused_seconds') ?? 0;
      final pausedMinutes = (pausedSeconds / 60).floor();
      
      await api.stopStudySession(durationMinutes, pausedMinutes: pausedMinutes);
      
      await prefs.remove('study_session_start');
      await prefs.remove('study_session_id');
      await prefs.remove('last_motion_detected');
      await prefs.remove('paused_seconds');
      await prefs.remove('is_paused');
      
      await ref.read(studySessionServiceProvider).stopService();
      
      ref.invalidate(studyHistoryProvider);
      
      state = state.copyWith(
        status: StudySessionStatus.idle,
        startTime: null,
        currentSession: null,
        elapsed: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudySessionStatus.error,
        errorMessage: 'Failed to stop session. Ensure you have network connectivity.',
      );
      // Fallback: we still allow them to try again
      Future.delayed(const Duration(seconds: 3), () {
        try {
          if (state.status == StudySessionStatus.error) {
            state = state.copyWith(status: StudySessionStatus.active, errorMessage: null);
          }
        } catch (_) {}
      });
    }
  }
}

final studySessionProvider = NotifierProvider<StudySessionNotifier, StudySessionState>(StudySessionNotifier.new);

final studyHistoryProvider = StreamProvider<List<StudySession>>((ref) {
  final api = ref.watch(studentApiProvider);
  return api.studySessionHistoryStream();
});
