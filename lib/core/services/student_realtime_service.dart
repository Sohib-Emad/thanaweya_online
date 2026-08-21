import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Realtime subscription manager for the Student module.
/// Listens to live Postgres changes on courses, lessons, exams,
/// subscriptions, points/students, and notifications.
class StudentRealtimeService {
  StudentRealtimeService._();
  static final StudentRealtimeService instance = StudentRealtimeService._();

  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  final List<VoidCallback> _onDataChangedListeners = [];
  final List<VoidCallback> _onPointsChangedListeners = [];
  final List<VoidCallback> _onCoursesChangedListeners = [];
  final List<VoidCallback> _onExamsChangedListeners = [];

  bool _isSubscribed = false;

  /// Registers listeners for global student data updates.
  void addDataListener(VoidCallback listener) =>
      _onDataChangedListeners.add(listener);
  void removeDataListener(VoidCallback listener) =>
      _onDataChangedListeners.remove(listener);

  void addPointsListener(VoidCallback listener) =>
      _onPointsChangedListeners.add(listener);
  void removePointsListener(VoidCallback listener) =>
      _onPointsChangedListeners.remove(listener);

  void addCoursesListener(VoidCallback listener) =>
      _onCoursesChangedListeners.add(listener);
  void removeCoursesListener(VoidCallback listener) =>
      _onCoursesChangedListeners.remove(listener);

  void addExamsListener(VoidCallback listener) =>
      _onExamsChangedListeners.add(listener);
  void removeExamsListener(VoidCallback listener) =>
      _onExamsChangedListeners.remove(listener);

  /// Initializes the Realtime channel subscription.
  void init() {
    if (_isSubscribed) return;
    try {
      final uid = _client.auth.currentUser?.id;
      final channelName = 'student_realtime_${uid ?? "guest"}_${DateTime.now().millisecondsSinceEpoch}';

      _channel = _client.channel(channelName);

      // 1. Courses updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'courses',
        callback: (_) => _notifyCourses(),
      );

      // 2. Lessons updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'lessons',
        callback: (_) => _notifyCourses(),
      );

      // 3. Subscriptions updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'subscriptions',
        callback: (_) {
          _notifyCourses();
          _notifyData();
        },
      );

      // 4. Students updates (bonus points, tier changes)
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'students',
        callback: (_) {
          _notifyPoints();
          _notifyData();
        },
      );

      // 5. Exams & Submissions
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'exams',
        callback: (_) => _notifyExams(),
      );

      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'exam_submissions',
        callback: (_) {
          _notifyExams();
          _notifyPoints();
          _notifyData();
        },
      );

      _channel?.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _isSubscribed = true;
          debugPrint('[StudentRealtimeService] Realtime channel connected ✅');
        } else if (error != null) {
          debugPrint('[StudentRealtimeService] Realtime subscription error: $error');
        }
      });
    } catch (e) {
      debugPrint('[StudentRealtimeService] init error: $e');
    }
  }

  void _notifyData() {
    for (final cb in List<VoidCallback>.from(_onDataChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  void _notifyPoints() {
    for (final cb in List<VoidCallback>.from(_onPointsChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  void _notifyCourses() {
    for (final cb in List<VoidCallback>.from(_onCoursesChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  void _notifyExams() {
    for (final cb in List<VoidCallback>.from(_onExamsChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  /// Cleans up Realtime channel.
  void dispose() {
    try {
      if (_channel != null) {
        _client.removeChannel(_channel!);
        _channel = null;
      }
    } catch (_) {}
    _isSubscribed = false;
    _onDataChangedListeners.clear();
    _onPointsChangedListeners.clear();
    _onCoursesChangedListeners.clear();
    _onExamsChangedListeners.clear();
  }
}
