import 'package:supabase_flutter/supabase_flutter.dart';

/// Enrichment helpers: question counts, teacher names, course titles, attempts.
class StudentExamsEnrichmentRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, int>> countQuestions(
    List<Map<String, dynamic>> exams,
  ) async {
    final map = <String, int>{};
    final examIds = exams
        .map((e) => e['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    if (examIds.isEmpty) return map;
    try {
      final rows = await _client
          .from('questions')
          .select('id, exam_id')
          .inFilter('exam_id', examIds);
      for (final q in rows) {
        final eId = q['exam_id'] as String? ?? '';
        if (eId.isNotEmpty) map[eId] = (map[eId] ?? 0) + 1;
      }
    } catch (_) {}
    return map;
  }

  Future<Map<String, String>> resolveTeacherNames(
    List<Map<String, dynamic>> exams,
  ) async {
    final ids = exams
        .map((e) => e['teacher_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (ids.isEmpty) return {};
    try {
      final users = await _client
          .from('users')
          .select('id, full_name')
          .inFilter('id', ids);
      return {
        for (final u in users)
          (u['id'] as String? ?? ''): u['full_name'] as String? ?? '',
      };
    } catch (_) {}
    return {};
  }

  Future<Map<String, String>> resolveCourseTitles(
    List<Map<String, dynamic>> exams,
  ) async {
    final ids = exams
        .map((e) => e['course_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (ids.isEmpty) return {};
    try {
      final courses = await _client
          .from('courses')
          .select('id, title')
          .inFilter('id', ids);
      return {
        for (final c in courses)
          (c['id'] as String? ?? ''): c['title'] as String? ?? '',
      };
    } catch (_) {}
    return {};
  }

  /// Attempts used per exam id for a student.
  Future<Map<String, int>> getAttemptsCounts(
    String studentId,
    List<Map<String, dynamic>> exams,
  ) async {
    final map = <String, int>{};
    if (exams.isEmpty) return map;
    try {
      final submissions = await _client
          .from('exam_submissions')
          .select('exam_id')
          .eq('student_id', studentId)
          .inFilter('exam_id', exams.map((e) => e['id'] as String).toList());
      for (final row in submissions) {
        final examId = row['exam_id'] as String?;
        if (examId != null) map[examId] = (map[examId] ?? 0) + 1;
      }
    } catch (_) {}
    return map;
  }
}
