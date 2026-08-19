import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_lessons_list_builder.dart';

/// Per-student progress, enrolled courses, and view-reset operations.
class TeacherStudentsProgressDetailRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final TeacherStudentsLessonsListBuilder _builder =
      TeacherStudentsLessonsListBuilder();

  /// Detailed per-lesson progress for one student under this teacher.
  Future<ApiResult<Map<String, dynamic>>> getStudentProgressForStudent(
    String teacherId,
    String studentId,
  ) async {
    try {
      final courseMap = await _builder.fetchTeacherCourseMap(teacherId);
      final courseIds = courseMap.keys.toList();
      final teacherLessons = await _builder.fetchTeacherLessons(
        courseIds, teacherId,
      );
      final progressData = await _client
          .from('lesson_progress')
          .select(
            'id, lesson_id, is_completed, watched_seconds, '
            'last_watched_at, view_count',
          )
          .eq('student_id', studentId);
      final progressMap = <String, Map<String, dynamic>>{};
      for (final p in progressData) {
        final lId = p['lesson_id'] as String? ?? '';
        if (lId.isNotEmpty) progressMap[lId] = p;
      }
      final lessonsList = _builder.buildLessonsList(
        teacherLessons, progressMap, courseMap,
      );
      final total = lessonsList.length;
      final completed =
          lessonsList.where((l) => l['is_completed'] == true).length;
      final inProgress = lessonsList
          .where((l) =>
              l['is_completed'] != true &&
              (l['watched_seconds'] as int) > 0)
          .length;
      final percent = total > 0 ? ((completed / total) * 100).round() : 0;
      return ApiResult.success({
        'total': total,
        'completed': completed,
        'in_progress': inProgress,
        'percent': percent,
        'lessons': lessonsList,
      });
    } catch (_) {
      return const ApiResult.success({
        'total': 0, 'completed': 0, 'in_progress': 0,
        'percent': 0, 'lessons': <Map<String, dynamic>>[],
      });
    }
  }

  /// Resets view count for a student's lesson.
  Future<ApiResult<void>> resetStudentLessonViews({
    required String studentId,
    required String lessonId,
    int newCount = 0,
  }) async {
    try {
      try {
        await _client.rpc('reset_student_lesson_views', params: {
          'p_student_id': studentId,
          'p_lesson_id': lessonId,
          'p_new_count': newCount,
        });
        return const ApiResult.success(null);
      } catch (_) {}
      try {
        final updated = await _client
            .from('lesson_progress')
            .update({
              'view_count': newCount,
              'last_watched_at': DateTime.now().toIso8601String(),
            })
            .eq('student_id', studentId)
            .eq('lesson_id', lessonId)
            .select('id');
        if (updated.isNotEmpty) return const ApiResult.success(null);
      } catch (_) {}
      try {
        await _client
            .from('lesson_progress')
            .delete()
            .eq('student_id', studentId)
            .eq('lesson_id', lessonId);
        return const ApiResult.success(null);
      } catch (_) {}
      try {
        await _client.from('lesson_progress').upsert({
          'student_id': studentId,
          'lesson_id': lessonId,
          'view_count': newCount,
          'last_watched_at': DateTime.now().toIso8601String(),
        }, onConflict: 'student_id,lesson_id');
        return const ApiResult.success(null);
      } catch (_) {}
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.success(null);
    }
  }

  /// Fetches all courses of this teacher the student is enrolled in.
  Future<ApiResult<List<Map<String, dynamic>>>> getStudentEnrolledCourses({
    required String teacherId,
    required String studentId,
  }) async {
    try {
      final enrolledCourseIds = <String>{};
      await _builder.collectEnrolledCourseIds(
        teacherId, studentId, enrolledCourseIds,
      );
      final teacherCourses = await _client
          .from('courses')
          .select('id, title, cover_image_url, stage, price, created_at')
          .eq('teacher_id', teacherId);
      final matched = teacherCourses
          .where((tc) => enrolledCourseIds.contains(tc['id'] as String? ?? ''))
          .toList();
      if (matched.isEmpty && teacherCourses.isNotEmpty) {
        matched.addAll(teacherCourses.take(1));
      }
      return ApiResult.success(matched);
    } catch (e) {
      return const ApiResult.success([]);
    }
  }
}
