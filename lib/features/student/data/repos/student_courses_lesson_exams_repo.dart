import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Fetches published exams linked to a lesson with attempt usage merged in.
class StudentCoursesLessonExamsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Published exams for a lesson, with attempt usage merged in.
  Future<ApiResult<List<Map<String, dynamic>>>> getLessonExams({
    required String lessonId,
    required String studentId,
  }) async {
    try {
      List<dynamic> data = [];
      try {
        data = await _client
            .from('exams')
            .select(
              'id, teacher_id, course_id, lesson_id, title, duration_minutes, '
              'start_at, end_at, max_score, max_attempts, is_published, '
              'created_at, questions(count)',
            )
            .eq('lesson_id', lessonId)
            .eq('is_published', true)
            .order('created_at', ascending: false);
      } catch (_) {
        data = await _client
            .from('exams')
            .select(
              'id, teacher_id, course_id, lesson_id, title, duration_minutes, '
              'start_at, end_at, max_score, max_attempts, is_published, '
              'created_at, questions(count)',
            )
            .eq('lesson_id', lessonId)
            .order('created_at', ascending: false);
      }
      var attemptsMap = <String, int>{};
      if (data.isNotEmpty && studentId.isNotEmpty) {
        try {
          final submissions = await _client
              .from('exam_submissions')
              .select('exam_id')
              .eq('student_id', studentId)
              .inFilter(
                'exam_id',
                data.map((e) => e['id'] as String).toList(),
              );
          for (final row in submissions) {
            final examId = row['exam_id'] as String?;
            if (examId == null) continue;
            attemptsMap[examId] = (attemptsMap[examId] ?? 0) + 1;
          }
        } catch (_) {}
      }
      final result = <Map<String, dynamic>>[];
      for (final raw in data) {
        final exam = Map<String, dynamic>.from(raw as Map);
        final examId = exam['id'] as String? ?? '';
        final maxAttempts = (exam['max_attempts'] as num?)?.toInt() ?? 3;
        result.add({
          ...exam,
          'max_attempts': maxAttempts,
          'attempts_used': attemptsMap[examId] ?? 0,
        });
      }
      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
