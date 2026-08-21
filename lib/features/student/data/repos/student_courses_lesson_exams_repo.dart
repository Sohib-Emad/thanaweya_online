import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Fetches published exams linked to a lesson with attempt usage and question count merged in.
class StudentCoursesLessonExamsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Published exams for a lesson, with attempt usage merged in.
  Future<ApiResult<List<Map<String, dynamic>>>> getLessonExams({
    required String lessonId,
    required String studentId,
  }) async {
    final cleanLessonId = lessonId.trim();
    if (cleanLessonId.isEmpty) return const ApiResult.success([]);
    try {
      List<dynamic> rawRows = [];
      const fields =
          'id, teacher_id, course_id, lesson_id, title, duration_minutes, '
          'start_at, end_at, max_score, passing_score, allow_retake, max_attempts, '
          'shuffle_questions, is_published, created_at';

      // 1. Query exams by lesson_id
      try {
        rawRows = await _client
            .from('exams')
            .select(fields)
            .eq('lesson_id', cleanLessonId)
            .order('created_at', ascending: false);
      } catch (e) {
        debugPrint('[LessonExamsRepo] query with fields failed: $e');
        try {
          rawRows = await _client
              .from('exams')
              .select('*')
              .eq('lesson_id', lessonId)
              .order('created_at', ascending: false);
        } catch (_) {}
      }

      // 2. Filter published exams (true or not explicitly false)
      final activeExams = rawRows.where((r) {
        final pub = r['is_published'];
        return pub == null || pub == true;
      }).toList();

      if (activeExams.isEmpty) {
        return const ApiResult.success([]);
      }

      final examIds = activeExams
          .map((e) => e['id'] as String?)
          .whereType<String>()
          .toList();

      // 3. Count attempts used by this student
      final attemptsMap = <String, int>{};
      if (examIds.isNotEmpty && studentId.isNotEmpty) {
        try {
          final submissions = await _client
              .from('exam_submissions')
              .select('exam_id')
              .eq('student_id', studentId)
              .inFilter('exam_id', examIds);

          for (final row in submissions) {
            final examId = row['exam_id'] as String?;
            if (examId == null) continue;
            attemptsMap[examId] = (attemptsMap[examId] ?? 0) + 1;
          }
        } catch (e) {
          debugPrint('[LessonExamsRepo] submissions count error: $e');
        }
      }

      // 4. Count questions for each exam
      final questionCounts = <String, int>{};
      if (examIds.isNotEmpty) {
        try {
          final qRows = await _client
              .from('questions')
              .select('exam_id')
              .inFilter('exam_id', examIds);

          for (final q in qRows) {
            final eId = q['exam_id'] as String?;
            if (eId != null) {
              questionCounts[eId] = (questionCounts[eId] ?? 0) + 1;
            }
          }
        } catch (e) {
          debugPrint('[LessonExamsRepo] questions count error: $e');
        }
      }

      // 5. Build final list
      final result = <Map<String, dynamic>>[];
      for (final raw in activeExams) {
        final exam = Map<String, dynamic>.from(raw as Map);
        final examId = exam['id'] as String? ?? '';
        final allowRetake = exam['allow_retake'] as bool? ?? false;
        final maxAttempts =
            (exam['max_attempts'] as num?)?.toInt() ?? (allowRetake ? 3 : 1);
        final qCount = questionCounts[examId] ?? 0;

        result.add({
          ...exam,
          'max_attempts': maxAttempts,
          'attempts_used': attemptsMap[examId] ?? 0,
          'questions': [{'count': qCount}],
          'question_count': qCount,
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      debugPrint('[LessonExamsRepo] getLessonExams error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
