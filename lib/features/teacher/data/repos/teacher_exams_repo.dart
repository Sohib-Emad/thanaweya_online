import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';

class TeacherExamsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<ExamModel>>> getExams(String teacherId) async {
    try {
      final data = await _client
          .from('exams')
          .select()
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);
      return ApiResult.success(
        data.map((e) => ExamModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<ExamModel>> createExam({
    required String teacherId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    String? courseId,
  }) async {
    try {
      final data = await _client
          .from('exams')
          .insert({
            'teacher_id': teacherId,
            'title': title,
            'duration_minutes': durationMinutes,
            'start_at': startAt.toIso8601String(),
            'end_at': endAt.toIso8601String(),
            'course_id': courseId,
          })
          .select()
          .single();
      return ApiResult.success(ExamModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateExam({
    required String examId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    String? courseId,
    bool? isPublished,
  }) async {
    try {
      await _client.from('exams').update({
        'title': title,
        'duration_minutes': durationMinutes,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        if (courseId != null) 'course_id': courseId,
        if (isPublished != null) 'is_published': isPublished,
      }).eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteExam(String examId) async {
    try {
      await _client.from('exams').delete().eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> publishExam(String examId) async {
    try {
      await _client
          .from('exams')
          .update({'is_published': true}).eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> setExamPublished(
      String examId, bool isPublished) async {
    try {
      await _client
          .from('exams')
          .update({'is_published': isPublished}).eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<Map<String, Map<String, int>>>> getExamQuestionStats(
      String teacherId) async {
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
        entry['points'] = entry['points']! + ((row['points'] as num?)?.toInt() ?? 0);
        stats[examId] = entry;
      }
      return ApiResult.success(stats);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Returns all submissions for an exam with the student's full name.
  Future<ApiResult<List<Map<String, dynamic>>>> getExamSubmissions(
      String examId) async {
    try {
      final data = await _client.from('exam_submissions').select('''
            id, score, total_points, started_at, submitted_at,
            students!inner(users!inner(full_name))
          ''').eq('exam_id', examId).order('submitted_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

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

  Future<ApiResult<QuestionModel>> addQuestion({
    required String examId,
    required String questionType,
    required String text,
    required List<String> options,
    String? correctAnswer,
    required int points,
  }) async {
    try {
      final data = await _client
          .from('questions')
          .insert({
            'exam_id': examId,
            'question_type': questionType,
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

  Future<ApiResult<void>> deleteQuestion(String questionId) async {
    try {
      await _client.from('questions').delete().eq('id', questionId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
