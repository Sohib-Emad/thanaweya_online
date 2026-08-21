import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds the per-lesson progress list for one student under a teacher.
class TeacherStudentsLessonsListBuilder {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, String>> fetchTeacherCourseMap(String teacherId) async {
    final map = <String, String>{};
    try {
      final teacherCourses = await _client
          .from('courses')
          .select('id, title')
          .eq('teacher_id', teacherId);
      for (final c in teacherCourses) {
        final cid = c['id'] as String? ?? '';
        if (cid.isNotEmpty) map[cid] = c['title'] as String? ?? '';
      }
    } catch (_) {}

    // Fallback: check if teacherId is a user_id
    if (map.isEmpty) {
      try {
        final tRow = await _client
            .from('teachers')
            .select('id')
            .or('id.eq.$teacherId,user_id.eq.$teacherId')
            .maybeSingle();
        final actualTid = tRow?['id'] as String?;
        if (actualTid != null && actualTid != teacherId) {
          final courses = await _client
              .from('courses')
              .select('id, title')
              .eq('teacher_id', actualTid);
          for (final c in courses) {
            final cid = c['id'] as String? ?? '';
            if (cid.isNotEmpty) map[cid] = c['title'] as String? ?? '';
          }
        }
      } catch (_) {}
    }

    return map;
  }

  Future<List<Map<String, dynamic>>> fetchTeacherLessons(
    List<String> courseIds,
    String teacherId,
  ) async {
    final list = <Map<String, dynamic>>[];
    if (courseIds.isNotEmpty) {
      try {
        final lRes = await _client
            .from('lessons')
            .select('id, title, duration_seconds, "order", course_id, max_views')
            .inFilter('course_id', courseIds)
            .order('order', ascending: true);
        list.addAll(lRes.cast<Map<String, dynamic>>());
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }
    try {
      final lRes = await _client
          .from('lessons')
          .select(
            'id, title, duration_seconds, "order", course_id, max_views, '
            'courses!inner(id, title, teacher_id)',
          )
          .eq('courses.teacher_id', teacherId)
          .order('order', ascending: true);
      list.addAll(lRes.cast<Map<String, dynamic>>());
    } catch (_) {}
    return list;
  }

  List<Map<String, dynamic>> buildLessonsList(
    List<Map<String, dynamic>> lessons,
    Map<String, Map<String, dynamic>> progressMap,
    Map<String, String> courseMap,
  ) {
    final result = <Map<String, dynamic>>[];
    final seenLessons = <String>{};

    for (final lesson in lessons) {
      final lessonId = lesson['id'] as String? ?? '';
      final courseId = lesson['course_id'] as String? ?? '';
      if (lessonId.isNotEmpty) seenLessons.add(lessonId);

      final prog = progressMap[lessonId];
      final watchedSec = (prog?['watched_seconds'] as num?)?.toInt() ?? 0;
      final viewCount = (prog?['view_count'] as num?)?.toInt() ?? 0;
      final isCompleted = prog?['is_completed'] == true ||
          prog?['is_completed'] == 1 ||
          prog?['is_completed'] == 'true' ||
          watchedSec > 0 ||
          viewCount > 0;
      final courseTitle = courseMap[courseId] ??
          (lesson['courses'] as Map<String, dynamic>?)?['title'] ??
          'دروس الدورة التعليمية';

      result.add({
        'id': prog?['id'] ?? lessonId,
        'lesson_id': lessonId,
        'title': lesson['title'] ?? 'درس',
        'course_id': courseId,
        'course_title': courseTitle,
        'is_completed': isCompleted,
        'watched_seconds': watchedSec,
        'duration_seconds': (lesson['duration_seconds'] as num?)?.toInt() ?? 0,
        'last_watched_at': prog?['last_watched_at'],
        'view_count': viewCount,
        'max_views': (lesson['max_views'] as num?)?.toInt() ?? 3,
      });
    }

    // Also include any progress items that have watched_seconds or view_count
    for (final entry in progressMap.entries) {
      if (!seenLessons.contains(entry.key)) {
        final prog = entry.value;
        final watchedSec = (prog['watched_seconds'] as num?)?.toInt() ?? 0;
        final viewCount = (prog['view_count'] as num?)?.toInt() ?? 0;
        final lessonInfo = prog['lessons'] as Map<String, dynamic>?;
        final courseInfo = lessonInfo?['courses'] as Map<String, dynamic>?;
        final cTitle = courseInfo?['title'] ??
            courseMap[lessonInfo?['course_id']] ??
            'دروس الدورة التعليمية';

        result.add({
          'id': prog['id'] ?? entry.key,
          'lesson_id': entry.key,
          'title': lessonInfo?['title'] ?? 'درس',
          'course_id': lessonInfo?['course_id'] ?? '',
          'course_title': cTitle,
          'is_completed': prog['is_completed'] == true || watchedSec > 0 || viewCount > 0,
          'watched_seconds': watchedSec,
          'duration_seconds': (lessonInfo?['duration_seconds'] as num?)?.toInt() ?? 0,
          'last_watched_at': prog['last_watched_at'],
          'view_count': viewCount,
          'max_views': (lessonInfo?['max_views'] as num?)?.toInt() ?? 3,
        });
      }
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
          .eq('used_by', studentId);
      for (final c in codes) {
        final cid = c['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) ids.add(cid);
      }
    } catch (_) {}
    try {
      final pays = await _client
          .from('payments')
          .select('course_id')
          .or('user_id.eq.$studentId,student_id.eq.$studentId,payer_id.eq.$studentId')
          .eq('status', 'success');
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
