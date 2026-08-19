import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';

/// Question CRUD operations extracted from [TeacherExamsRepo].
class TeacherExamsQuestionRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Returns question count and total points per exam for a teacher.
  Future<ApiResult<Map<String, Map<String, int>>>> getExamQuestionStats(
    String teacherId,
  ) async {
    try {
      final data = await _client
          .from('questions')
          .select('exam_id, points, exams!inner(teacher_id)')
          .eq('exams.teacher_id', teacherId);
      final stats = <String, Map<String, int>>{};
      for (final row in data) {
        final examId = row['exam_id'] as String?;
        if (examId == null) continue;
        final entry = stats[examId] ?? {'count': 0, 'points': 0};
        entry['count'] = entry['count']! + 1;
        entry['points'] =
            entry['points']! + ((row['points'] as num?)?.toInt() ?? 0);
        stats[examId] = entry;
      }
      return ApiResult.success(stats);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Lists questions for an exam ordered by "order".
  Future<ApiResult<List<QuestionModel>>> getQuestions(String examId) async {
    try {
      final data = await _client
          .from('questions')
          .select()
          .eq('exam_id', examId)
          .order('order');
      return ApiResult.success(
        data.map((e) => QuestionModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Adds a question to an exam.
  Future<ApiResult<QuestionModel>> addQuestion({
    required String examId,
    required String questionType,
    required String text,
    required List<String> options,
    String? correctAnswer,
    required int points,
  }) async {
    try {
      final validType = (questionType == 'true_false' || questionType == 'tf')
          ? 'true_false'
          : (questionType == 'essay' ? 'essay' : 'mcq');
      final data = await _client
          .from('questions')
          .insert({
            'exam_id': examId,
            'question_type': validType,
            'text': text,
            'options': options,
            'correct_answer': correctAnswer,
            'points': points,
          })
          .select()
          .single();
      return ApiResult.success(QuestionModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes a question by id.
  Future<ApiResult<void>> deleteQuestion(String questionId) async {
    try {
      await _client.from('questions').delete().eq('id', questionId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
