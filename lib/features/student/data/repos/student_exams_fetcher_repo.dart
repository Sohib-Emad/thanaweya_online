import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches exams by teacher or course IDs with deduplication.
class StudentExamsFetcherRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchExams(
    Set<String> teacherIds,
    Set<String> courseIds,
  ) async {
    final exams = <Map<String, dynamic>>[];
    final seen = <String>{};
    const fields =
        'id, teacher_id, course_id, lesson_id, title, duration_minutes, '
        'start_at, end_at, max_score, max_attempts, is_published, created_at';
    if (courseIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('exams')
            .select(fields)
            .inFilter('course_id', courseIds.toList())
            .order('created_at', ascending: false);
        for (final e in rows) {
          final id = e['id'] as String? ?? '';
          if (id.isNotEmpty && (e['is_published'] as bool? ?? true) && seen.add(id)) {
            exams.add(e);
          }
        }
      } catch (_) {}
    }
    if (teacherIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('exams')
            .select(fields)
            .inFilter('teacher_id', teacherIds.toList())
            .order('created_at', ascending: false);
        for (final e in rows) {
          final id = e['id'] as String? ?? '';
          if (id.isNotEmpty && (e['is_published'] as bool? ?? true) && seen.add(id)) {
            exams.add(e);
          }
        }
      } catch (_) {}
    }
    return exams;
  }
}
