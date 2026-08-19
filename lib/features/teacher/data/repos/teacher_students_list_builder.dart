import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';

/// Builds the enriched student list for the teacher's dashboard.
class TeacherStudentsListBuilder {
  final SupabaseClient _client = Supabase.instance.client;

  /// Collects all student IDs associated with this teacher from
  /// subscriptions, activation codes, and exam submissions.
  Future<void> collectStudentIds(
    String teacherId,
    Set<String> ids,
    Map<String, String> statusMap,
    Map<String, String> dateMap,
  ) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('id, student_id, status, created_at')
          .eq('teacher_id', teacherId);
      for (final sub in subData) {
        final sId = sub['student_id'] as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap[sId] = sub['status'] as String? ?? 'active';
          dateMap[sId] = sub['created_at'] as String? ?? '';
        }
      }
    } catch (_) {}
    try {
      final codesData = await _client
          .from('activation_codes')
          .select('used_by_student_id, used_at, created_at')
          .eq('teacher_id', teacherId)
          .eq('is_used', true)
          .not('used_by_student_id', 'is', null);
      for (final code in codesData) {
        final sId = code['used_by_student_id'] as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap.putIfAbsent(sId, () => 'active');
          dateMap.putIfAbsent(sId, () => code['used_at'] as String? ?? '');
        }
      }
    } catch (_) {}
    try {
      final examsData = await _client
          .from('exam_submissions')
          .select('student_id, submitted_at, exams!inner(teacher_id)')
          .eq('exams.teacher_id', teacherId);
      for (final item in examsData) {
        final sId = item['student_id'] as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap.putIfAbsent(sId, () => 'active');
          dateMap.putIfAbsent(
              sId, () => item['submitted_at'] as String? ?? '');
        }
      }
    } catch (_) {}
  }

  /// Builds the enriched student list with progress info.
  Future<ApiResult<List<Map<String, dynamic>>>> buildStudentsResult(
    String teacherId,
    List<String> studentIds,
    Map<String, String> statusMap,
    Map<String, String> dateMap,
  ) async {
    List<Map<String, dynamic>> studentsData = [];
    try {
      studentsData = await _client
          .from('students')
          .select('id, grade_level, parent_phone, created_at')
          .inFilter('id', studentIds);
    } catch (_) {}

    final progressMap = <String, int>{};
    int teacherLessonsCount = 0;
    try {
      final teacherCourses = await _client
          .from('courses').select('id').eq('teacher_id', teacherId);
      final courseIds = teacherCourses
          .map((c) => c['id'] as String?).whereType<String>().toList();
      if (courseIds.isNotEmpty) {
        final tLessons = await _client
            .from('lessons').select('id').inFilter('course_id', courseIds);
        teacherLessonsCount = tLessons.length;
        final lessonIds = tLessons
            .map((l) => l['id'] as String?).whereType<String>().toList();
        if (lessonIds.isNotEmpty && studentIds.isNotEmpty) {
          final progRows = await _client
              .from('lesson_progress')
              .select('student_id, is_completed, watched_seconds, view_count')
              .inFilter('student_id', studentIds)
              .inFilter('lesson_id', lessonIds);
          for (final p in progRows) {
            final sId = p['student_id'] as String? ?? '';
            final isDone = p['is_completed'] == true ||
                p['is_completed'] == 1 ||
                p['is_completed'] == 'true' ||
                (p['watched_seconds'] as num? ?? 0) > 0 ||
                (p['view_count'] as num? ?? 0) > 0;
            if (sId.isNotEmpty && isDone) {
              progressMap[sId] = (progressMap[sId] ?? 0) + 1;
            }
          }
        }
      }
    } catch (_) {}

    final usersData = await StudentUserLookup().forIds(studentIds);
    final studentsMap = {
      for (final s in studentsData)
        if (s['id'] != null) (s['id'] as String? ?? ''): s,
    };
    final result = <Map<String, dynamic>>[];
    for (final sid in studentIds) {
      final done = progressMap[sid] ?? 0;
      final total = teacherLessonsCount;
      final percent = total > 0 ? ((done / total) * 100).round() : 0;
      result.add({
        'id': sid,
        'student_id': sid,
        'status': statusMap[sid] ?? 'active',
        'created_at': dateMap[sid] ?? '',
        'students': studentsMap[sid] ?? {},
        'users': usersData[sid] ?? {},
        'completed_lessons': done,
        'total_lessons': total,
        'progress_percent': percent,
      });
    }
    return ApiResult.success(result);
  }
}
