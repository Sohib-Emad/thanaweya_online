import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';

class StudentExamsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getAvailableExams(
      String studentId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client.from('exams').select('''
            id, title, duration_minutes, start_at, end_at, max_score, is_published, created_at,
            teachers!inner(id, subject_id,
              users!inner(id, full_name)
            )
          ''').eq('is_published', true).lte('start_at', now).gte('end_at', now);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<ExamModel>> getExam(String examId) async {
    try {
      final data = await _client
          .from('exams')
          .select()
          .eq('id', examId)
          .single();
      return ApiResult.success(ExamModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<QuestionModel>>> getExamQuestions(
      String examId) async {
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

  Future<ApiResult<void>> submitExam({
    required String examId,
    required String studentId,
    required int score,
    required int totalPoints,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _client.from('exam_submissions').insert({
        'exam_id': examId,
        'student_id': studentId,
        'score': score,
        'total_points': totalPoints,
        'answers': answers,
        'submitted_at': DateTime.now().toIso8601String(),
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentSubmissions(
      String studentId) async {
    try {
      final data = await _client.from('exam_submissions').select('''
            id, score, total_points, started_at, submitted_at, answers,
            exams!inner(id, title, duration_minutes, max_score)
          ''').eq('student_id', studentId).order('submitted_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
