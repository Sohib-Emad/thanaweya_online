import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_listing_repo.dart';

/// Facade that delegates exam listing to [StudentExamsListingRepo].
class StudentExamsRepo {
  final StudentExamsListingRepo listing = StudentExamsListingRepo();

  final SupabaseClient _client = Supabase.instance.client;

  /// The authenticated student's user id, or null if not signed in.
  String? get currentUserId =>
      _client.auth.currentUser?.id ??
      _client.auth.currentSession?.user.id;

  /// The student's own attempts for one exam, newest first.
  Future<ApiResult<List<Map<String, dynamic>>>> getExamAttempts({
    required String examId,
    required String studentId,
  }) async {
    try {
      final data = await _client
          .from('exam_submissions')
          .select('id, score, total_points, submitted_at, started_at, time_spent_seconds')
          .eq('exam_id', examId)
          .eq('student_id', studentId)
          .order('submitted_at', ascending: true);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches a single exam by id.
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

  /// Fetches questions for an exam ordered by "order".
  Future<ApiResult<List<QuestionModel>>> getExamQuestions(String examId) async {
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

  /// Records the moment a student starts an exam on the server.
  ///
  /// This is stored in a temporary row in [exam_submissions] with only
  /// started_at so the timer can be verified server-side.
  /// The row is updated with the full result when the student submits.
  Future<void> recordExamStart({
    required String examId,
    required String studentId,
    required DateTime startedAt,
  }) async {
    try {
      // Check if a pending row already exists to avoid duplicates
      final existing = await _client
          .from('exam_submissions')
          .select('id')
          .eq('exam_id', examId)
          .eq('student_id', studentId)
          .filter('submitted_at', 'is', 'null')
          .maybeSingle();
      if (existing == null) {
        await _client.from('exam_submissions').insert({
          'exam_id': examId,
          'student_id': studentId,
          'started_at': startedAt.toUtc().toIso8601String(),
          'score': 0,
          'total_points': 0,
          'answers': {},
        });
      }
    } catch (_) {
      // Non-critical — local cache already has the start time
    }
  }

  /// Submits an exam attempt with idempotency support.
  ///
  /// Uses [localSubmissionId] as a unique key so the same attempt is never
  /// stored twice if the sync runs multiple times.
  Future<ApiResult<void>> submitExam({
    required String examId,
    required String studentId,
    required int score,
    required int totalPoints,
    required Map<String, dynamic> answers,
    DateTime? startedAt,
    DateTime? submittedAt,
    int? timeSpentSeconds,
    String? localSubmissionId,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      // Find and update the in-progress row if it exists, else insert fresh
      final inProgress = await _client
          .from('exam_submissions')
          .select('id')
          .eq('exam_id', examId)
          .eq('student_id', studentId)
          .filter('submitted_at', 'is', 'null')
          .maybeSingle();

      final payload = {
        'exam_id': examId,
        'student_id': studentId,
        'score': score,
        'total_points': totalPoints,
        'answers': answers,
        'started_at': (startedAt ?? now).toUtc().toIso8601String(),
        'submitted_at': (submittedAt ?? now).toIso8601String(),
        'time_spent_seconds': timeSpentSeconds,
        if (localSubmissionId != null)
          'local_submission_id': localSubmissionId,
        'is_pending_sync': false,
      };

      if (inProgress != null) {
        await _client
            .from('exam_submissions')
            .update(payload)
            .eq('id', inProgress['id'] as String);
      } else {
        // Idempotent upsert using local_submission_id
        if (localSubmissionId != null) {
          await _client.from('exam_submissions').upsert(
            payload,
            onConflict: 'local_submission_id',
            ignoreDuplicates: true,
          );
        } else {
          await _client.from('exam_submissions').insert(payload);
        }
      }
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// All submissions for this student across all exams.
  Future<ApiResult<List<Map<String, dynamic>>>> getStudentSubmissions(
    String studentId,
  ) async {
    try {
      final data = await _client.from('exam_submissions').select('''
            id, score, total_points, started_at, submitted_at, answers,
            time_spent_seconds,
            exams!inner(id, title, duration_minutes, max_score, passing_score)
          ''').eq('student_id', studentId).order('submitted_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
