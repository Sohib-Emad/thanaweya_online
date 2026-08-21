import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Realtime subscription manager for the Teacher module.
/// Listens to live Postgres changes on courses, lessons, exams, and subscriptions.
class TeacherRealtimeService {
  TeacherRealtimeService._();
  static final TeacherRealtimeService instance = TeacherRealtimeService._();

  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  final List<VoidCallback> _onCoursesChangedListeners = [];
  final List<VoidCallback> _onExamsChangedListeners = [];
  final List<VoidCallback> _onLessonsChangedListeners = [];
  final List<VoidCallback> _onDataChangedListeners = [];

  bool _isSubscribed = false;

  void addCoursesListener(VoidCallback listener) =>
      _onCoursesChangedListeners.add(listener);
  void removeCoursesListener(VoidCallback listener) =>
      _onCoursesChangedListeners.remove(listener);

  void addExamsListener(VoidCallback listener) =>
      _onExamsChangedListeners.add(listener);
  void removeExamsListener(VoidCallback listener) =>
      _onExamsChangedListeners.remove(listener);

  void addLessonsListener(VoidCallback listener) =>
      _onLessonsChangedListeners.add(listener);
  void removeLessonsListener(VoidCallback listener) =>
      _onLessonsChangedListeners.remove(listener);

  void addDataListener(VoidCallback listener) =>
      _onDataChangedListeners.add(listener);
  void removeDataListener(VoidCallback listener) =>
      _onDataChangedListeners.remove(listener);

  /// Initializes the Realtime channel for teacher events.
  void init() {
    if (_isSubscribed) return;
    try {
      final uid = _client.auth.currentUser?.id;
      final channelName = 'teacher_realtime_${uid ?? "guest"}_${DateTime.now().millisecondsSinceEpoch}';

      _channel = _client.channel(channelName);

      // 1. Courses updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'courses',
        callback: (_) {
          notifyCoursesChanged();
          notifyAll();
        },
      );

      // 2. Exams updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'exams',
        callback: (_) {
          notifyExamsChanged();
          notifyAll();
        },
      );

      // 3. Lessons updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'lessons',
        callback: (_) {
          notifyLessonsChanged();
          notifyCoursesChanged();
          notifyAll();
        },
      );

      // 4. Exam submissions updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'exam_submissions',
        callback: (_) {
          notifyExamsChanged();
          notifyAll();
        },
      );

      // 5. Subscriptions updates
      _channel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'subscriptions',
        callback: (_) => notifyAll(),
      );

      _channel?.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _isSubscribed = true;
          debugPrint('[TeacherRealtimeService] Realtime channel connected ✅');
        } else if (error != null) {
          debugPrint('[TeacherRealtimeService] Realtime note: $error');
        }
      });
    } catch (e) {
      debugPrint('[TeacherRealtimeService] init error: $e');
    }
  }

  /// Manually trigger courses refresh across all listeners
  void notifyCoursesChanged() {
    for (final cb in List<VoidCallback>.from(_onCoursesChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  /// Manually trigger exams refresh across all listeners
  void notifyExamsChanged() {
    for (final cb in List<VoidCallback>.from(_onExamsChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  /// Manually trigger lessons refresh across all listeners
  void notifyLessonsChanged() {
    for (final cb in List<VoidCallback>.from(_onLessonsChangedListeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  /// Manually trigger general data refresh across all listeners
  void notifyAll() {
    for (final cb in List<VoidCallback>.from(_onDataChangedListeners)) {
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
    _onCoursesChangedListeners.clear();
    _onExamsChangedListeners.clear();
    _onLessonsChangedListeners.clear();
    _onDataChangedListeners.clear();
  }
}
