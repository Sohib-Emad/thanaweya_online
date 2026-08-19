import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Exam grades and submissions for a specific student under a teacher.
class TeacherStudentsExamGradesRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// All exam submissions of one student across the teacher's exams.
  Future<ApiResult<List<Map<String, dynamic>>>> getStudentExamGrades({
    required String teacherId,
    required String studentId,
  }) async {
    try {
      final examMap = await _fetchTeacherExamMap(teacherId);
      final examIds = examMap.keys.toList();

      if (examIds.isNotEmpty) {
        try {
          final submissions = await _client
              .from('exam_submissions')
              .select(
                'id, score, total_points, started_at, submitted_at, exam_id',
              )
              .eq('student_id', studentId)
              .inFilter('exam_id', examIds)
              .order('submitted_at', ascending: false, nullsFirst: false);

          final result = <Map<String, dynamic>>[];
          for (final s in submissions) {
            final eId = s['exam_id'] as String? ?? '';
            result.add({
              ...s,
              'exams': examMap[eId] ??
                  {'id': eId, 'title': 'امتحان', 'max_score': 100},
            });
          }
          return ApiResult.success(result);
        } catch (_) {}
      }

      try {
        final data = await _client
            .from('exam_submissions')
            .select(
              'id, score, total_points, started_at, submitted_at, exam_id, '
              'exams!inner(id, title, max_score)',
            )
            .eq('student_id', studentId)
            .eq('exams.teacher_id', teacherId)
            .order('submitted_at', ascending: false, nullsFirst: false);
        return ApiResult.success(data);
      } catch (_) {}

      final fallbackData = await _client
          .from('exam_submissions')
          .select('id, score, total_points, started_at, submitted_at, exam_id')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false, nullsFirst: false);
      return ApiResult.success(fallbackData.cast<Map<String, dynamic>>());
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchTeacherExamMap(
    String teacherId,
  ) async {
    final teacherExams = await _client
        .from('exams')
        .select('id, title, max_score')
        .eq('teacher_id', teacherId);
    final map = <String, Map<String, dynamic>>{};
    for (final e in teacherExams) {
      final eid = e['id'] as String? ?? '';
      if (eid.isNotEmpty) map[eid] = e;
    }
    return map;
  }
}
