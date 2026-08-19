import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';

/// Submissions and grades operations for teacher exams.
class TeacherExamsSubmissionsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Returns all submissions for an exam with student names.
  Future<ApiResult<List<Map<String, dynamic>>>> getExamSubmissions(
    String examId,
  ) async {
    try {
      final data = await _client
          .from('exam_submissions')
          .select(
            'id, score, total_points, started_at, submitted_at, student_id',
          )
          .eq('exam_id', examId)
          .order('submitted_at', ascending: false);
      final studentIds = data
          .map((s) => s['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final names = await StudentUserLookup()
          .namesFor(studentIds, fallback: 'طالب');
      final enriched = data.map((s) {
        final sid = s['student_id'] as String? ?? '';
        return {
          ...s,
          'students': <String, dynamic>{
            'users': <String, dynamic>{
              'full_name': names[sid] ?? 'طالب',
            },
          },
        };
      }).toList();
      return ApiResult.success(enriched);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// All submissions across the teacher's exams.
  Future<ApiResult<List<Map<String, dynamic>>>> getExamGradesSummary(
    String teacherId,
  ) async {
    try {
      final data = await _client
          .from('exam_submissions')
          .select(
            'exam_id, student_id, score, total_points, submitted_at, '
            'exams!inner(teacher_id)',
          )
          .eq('exams.teacher_id', teacherId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Re-opens the exam for one student.
  Future<ApiResult<void>> resetStudentAttempts({
    required String examId,
    required String studentId,
  }) async {
    try {
      await _client
          .from('exam_submissions')
          .delete()
          .eq('exam_id', examId)
          .eq('student_id', studentId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Re-opens the exam for all students.
  Future<ApiResult<void>> resetAllAttempts(String examId) async {
    try {
      await _client.from('exam_submissions').delete().eq('exam_id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
