import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'exam_local_cache.dart';

/// Watches connectivity and syncs any pending exam submissions to Supabase.
///
/// Call [ExamSyncService.init()] once at app startup (or when the student
/// returns to the home screen).  It will immediately try to flush the queue
/// and also subscribe to connectivity changes.
class ExamSyncService {
  ExamSyncService._();

  static final _client = Supabase.instance.client;
  static bool _isSyncing = false;

  /// Starts connectivity-aware background sync.
  static Future<void> init() async {
    await _flushPending();
    Connectivity().onConnectivityChanged.listen((results) {
      final hasNetwork = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
      if (hasNetwork) _flushPending();
    });
  }

  /// Tries to send all queued submissions to the server.
  static Future<void> _flushPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final pending = await ExamLocalCache.loadPendingSubmissions();
      for (final submission in List<Map<String, dynamic>>.from(pending)) {
        await _sendSubmission(submission);
      }
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> _sendSubmission(Map<String, dynamic> sub) async {
    final localId = sub['local_submission_id'] as String?;
    if (localId == null) return;
    try {
      // Idempotent upsert — if the server already has this local_submission_id
      // the insert is ignored (requires UNIQUE constraint on the column).
      await _client.from('exam_submissions').upsert(
        {
          'exam_id': sub['exam_id'],
          'student_id': sub['student_id'],
          'score': sub['score'],
          'total_points': sub['total_points'],
          'answers': sub['answers'],
          'started_at': sub['started_at'],
          'submitted_at': sub['submitted_at'],
          'time_spent_seconds': sub['time_spent_seconds'],
          'local_submission_id': localId,
          'is_pending_sync': false,
        },
        onConflict: 'local_submission_id',
        ignoreDuplicates: true,
      );
      await ExamLocalCache.removePendingSubmission(localId);
    } catch (_) {
      // Keep it in the queue — will retry on next connectivity event.
    }
  }

  /// Manually trigger a sync (call after the exam is submitted offline).
  static Future<void> syncNow() => _flushPending();
}
