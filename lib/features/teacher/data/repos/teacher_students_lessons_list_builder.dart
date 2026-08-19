import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds the per-lesson progress list for one student under a teacher.
class TeacherStudentsLessonsListBuilder {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, String>> fetchTeacherCourseMap(String teacherId) async {
    final teacherCourses = await _client
        .from('courses')
        .select('id, title')
        .eq('teacher_id', teacherId);
    final map = <String, String>{};
    for (final c in teacherCourses) {
      final cid = c['id'] as String? ?? '';
      if (cid.isNotEmpty) map[cid] = c['title'] as String? ?? '';
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> fetchTeacherLessons(
    List<String> courseIds,
    String teacherId,
  ) async {
    if (courseIds.isEmpty) return [];
    try {
      final lRes = await _client
          .from('lessons')
          .select('id, title, duration_seconds, "order", course_id, max_views')
          .inFilter('course_id', courseIds)
          .order('order', ascending: true);
      final list = lRes.cast<Map<String, dynamic>>();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    try {
      final lRes = await _client
          .from('lessons')
          .select(
            'id, title, duration_seconds, "order", course_id, max_views, '
            'courses!inner(id, title, teacher_id)',
          )
          .eq('courses.teacher_id', teacherId)
          .order('order', ascending: true);
      return lRes.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  List<Map<String, dynamic>> buildLessonsList(
    List<Map<String, dynamic>> lessons,
    Map<String, Map<String, dynamic>> progressMap,
    Map<String, String> courseMap,
  ) {
    final result = <Map<String, dynamic>>[];
    for (final lesson in lessons) {
      final lessonId = lesson['id'] as String? ?? '';
      final courseId = lesson['course_id'] as String? ?? '';
      final prog = progressMap[lessonId];
      final isCompleted = prog?['is_completed'] == true ||
          prog?['is_completed'] == 1 ||
          prog?['is_completed'] == 'true' ||
          (prog?['watched_seconds'] as num? ?? 0) > 0 ||
          (prog?['view_count'] as num? ?? 0) > 0;
      final courseTitle = courseMap[courseId] ??
          (lesson['courses'] as Map<String, dynamic>?)?['title'] ?? '';
      result.add({
        'id': prog?['id'] ?? lessonId,
        'lesson_id': lessonId,
        'title': lesson['title'] ?? 'درس',
        'course_id': courseId,
        'course_title': courseTitle,
        'is_completed': isCompleted,
        'watched_seconds': (prog?['watched_seconds'] as num?)?.toInt() ?? 0,
        'duration_seconds': (lesson['duration_seconds'] as num?)?.toInt() ?? 0,
        'last_watched_at': prog?['last_watched_at'],
        'view_count': (prog?['view_count'] as num?)?.toInt() ?? 0,
        'max_views': (lesson['max_views'] as num?)?.toInt() ?? 5,
      });
    }
    return result;
  }

  Future<void> collectEnrolledCourseIds(
    String teacherId,
    String studentId,
    Set<String> ids,
  ) async {
    try {
      final subs = await _client
          .from('subscriptions')
          .select('course_id')
          .eq('teacher_id', teacherId)
          .eq('student_id', studentId);
      for (final s in subs) {
        final cid = s['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) ids.add(cid);
      }
    } catch (_) {}
    try {
      final codes = await _client
          .from('activation_codes')
          .select('course_id')
          .eq('teacher_id', teacherId)
          .or('used_by_student_id.eq.$studentId,used_by.eq.$studentId');
      for (final c in codes) {
        final cid = c['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) ids.add(cid);
      }
    } catch (_) {}
    try {
      final pays = await _client
          .from('payments')
          .select('course_id')
          .or('user_id.eq.$studentId,student_id.eq.$studentId')
          .inFilter('status', ['success', 'completed', 'active']);
      for (final p in pays) {
        final cid = p['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) ids.add(cid);
      }
    } catch (_) {}
    try {
      final progs = await _client
          .from('lesson_progress')
          .select('lesson_id, lessons(course_id)')
          .eq('student_id', studentId);
      for (final pr in progs) {
        final lessonObj = pr['lessons'] as Map<String, dynamic>?;
        final cid = lessonObj?['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) ids.add(cid);
      }
    } catch (_) {}
  }
}
