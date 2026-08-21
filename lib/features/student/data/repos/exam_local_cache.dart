import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys and helpers for caching exam state locally on the device.
class ExamLocalCache {
  ExamLocalCache._();

  static const _sessionPrefix = 'exam_session_';
  static const _pendingKey = 'pending_exam_submissions';

  // ──────────────────────────── Session ──────────────────────────────

  static Future<void> saveSession({
    required String examId,
    required String studentId,
    required DateTime startedAt,
    required Map<String, String> answers,
    required List<Map<String, dynamic>> questions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sessionKey(examId, studentId);
    final payload = {
      'started_at': startedAt.toUtc().toIso8601String(),
      'answers': answers,
      'questions': questions,
    };
    await prefs.setString(key, jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> loadSession({
    required String examId,
    required String studentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey(examId, studentId));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateAnswers({
    required String examId,
    required String studentId,
    required Map<String, String> answers,
  }) async {
    final session = await loadSession(examId: examId, studentId: studentId);
    if (session == null) return;
    session['answers'] = answers;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey(examId, studentId), jsonEncode(session));
  }

  static Future<void> clearSession({
    required String examId,
    required String studentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey(examId, studentId));
  }

  static Future<DateTime?> getStartedAt({
    required String examId,
    required String studentId,
  }) async {
    final session = await loadSession(examId: examId, studentId: studentId);
    final raw = session?['started_at'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static String _sessionKey(String examId, String studentId) =>
      '$_sessionPrefix${examId}_$studentId';

  // ──────────────────────── Pending Submissions ───────────────────────

  static Future<void> enqueuePendingSubmission(
    Map<String, dynamic> submission,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = _loadPendingList(prefs);
    final id = submission['local_submission_id'] as String?;
    if (id != null && existing.any((s) => s['local_submission_id'] == id)) {
      return;
    }
    existing.add(submission);
    await prefs.setString(_pendingKey, jsonEncode(existing));
  }

  static Future<List<Map<String, dynamic>>> loadPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadPendingList(prefs);
  }

  static Future<void> removePendingSubmission(String localSubmissionId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _loadPendingList(prefs);
    list.removeWhere((s) => s['local_submission_id'] == localSubmissionId);
    await prefs.setString(_pendingKey, jsonEncode(list));
  }

  static List<Map<String, dynamic>> _loadPendingList(SharedPreferences prefs) {
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
