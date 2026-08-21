import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_question_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_submissions_repo.dart';

/// Facade delegating to questions and submissions sub-repos.
class TeacherExamsRepo {
  final TeacherExamsQuestionRepo questions = TeacherExamsQuestionRepo();
  final TeacherExamsSubmissionsRepo submissions =
      TeacherExamsSubmissionsRepo();
  final SupabaseClient _client = Supabase.instance.client;

  /// Lists exams for a teacher, auto-publishing any unpublished ones.
  Future<ApiResult<List<ExamModel>>> getExams(String teacherId) async {
    try {
      try {
        await _client
            .from('exams')
            .update({'is_published': true})
            .eq('teacher_id', teacherId)
            .eq('is_published', false);
      } catch (_) {}
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

  /// Creates a new exam.
  Future<ApiResult<ExamModel>> createExam({
    required String teacherId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    String? courseId,
    String? lessonId,
    int passingScore = 50,
    bool allowRetake = false,
    int maxAttempts = 1,
    bool shuffleQuestions = false,
    bool isPublished = true,
  }) async {
    try {
      final data = await _client
          .from('exams')
          .insert({
            'teacher_id': teacherId,
            'title': title,
            'duration_minutes': durationMinutes,
            'start_at': startAt.toUtc().toIso8601String(),
            'end_at': endAt.toUtc().toIso8601String(),
            'course_id': courseId,
            'lesson_id': lessonId,
            'passing_score': passingScore,
            'allow_retake': allowRetake,
            'max_attempts': maxAttempts,
            'shuffle_questions': shuffleQuestions,
            'is_published': isPublished,
          })
          .select()
          .single();
      return ApiResult.success(ExamModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Updates an existing exam.
  Future<ApiResult<void>> updateExam({
    required String examId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    String? courseId,
    String? lessonId,
    int? passingScore,
    bool? allowRetake,
    int? maxAttempts,
    bool? shuffleQuestions,
    bool? clearLesson,
    bool? isPublished,
  }) async {
    try {
      final updates = <String, dynamic>{
        'title': title,
        'duration_minutes': durationMinutes,
        'start_at': startAt.toUtc().toIso8601String(),
        'end_at': endAt.toUtc().toIso8601String(),
      };
      if (courseId != null) updates['course_id'] = courseId;
      if (clearLesson == true) {
        updates['lesson_id'] = null;
      } else if (lessonId != null) {
        updates['lesson_id'] = lessonId;
      }
      if (passingScore != null) updates['passing_score'] = passingScore;
      if (allowRetake != null) updates['allow_retake'] = allowRetake;
      if (maxAttempts != null) updates['max_attempts'] = maxAttempts;
      if (shuffleQuestions != null) updates['shuffle_questions'] = shuffleQuestions;
      if (isPublished != null) updates['is_published'] = isPublished;
      await _client.from('exams').update(updates).eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes an exam by id.
  Future<ApiResult<void>> deleteExam(String examId) async {
    try {
      await _client.from('exams').delete().eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Publishes an exam.
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

  /// Sets the published state of an exam.
  Future<ApiResult<void>> setExamPublished(
    String examId,
    bool isPublished,
  ) async {
    try {
      await _client
          .from('exams')
          .update({'is_published': isPublished}).eq('id', examId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Delegates to submissions sub-repo.
  Future<ApiResult<List<Map<String, dynamic>>>> getExamSubmissions(
    String examId,
  ) =>
      submissions.getExamSubmissions(examId);

  /// Delegates to submissions sub-repo.
  Future<ApiResult<void>> resetStudentAttempts({
    required String examId,
    required String studentId,
  }) =>
      submissions.resetStudentAttempts(examId: examId, studentId: studentId);

  /// Delegates to submissions sub-repo.
  Future<ApiResult<void>> resetAllAttempts(String examId) =>
      submissions.resetAllAttempts(examId);

  /// Delegates to submissions sub-repo.
  Future<ApiResult<List<Map<String, dynamic>>>> getExamGradesSummary(
    String teacherId,
  ) =>
      submissions.getExamGradesSummary(teacherId);
}
