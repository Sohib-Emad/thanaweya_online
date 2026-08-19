import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_lessons_detail_repo.dart';

/// Lesson CRUD and progress operations. View/document/exam methods
/// live in [StudentCoursesLessonsDetailRepo].
class StudentCoursesLessonsRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final StudentCoursesLessonsDetailRepo detail =
      StudentCoursesLessonsDetailRepo();

  /// Fetches lessons for a course ordered by "order".
  Future<ApiResult<List<LessonModel>>> getCourseLessons(String courseId) async {
    try {
      final data = await _client
          .from('lessons')
          .select()
          .eq('course_id', courseId)
          .order('order');
      return ApiResult.success(
        data.map((e) => LessonModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Updates or inserts student lesson progress.
  Future<ApiResult<void>> updateLessonProgress({
    required String studentId,
    required String lessonId,
    required int watchedSeconds,
    required bool isCompleted,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id ?? studentId;
      if (uid.isEmpty) return const ApiResult.success(null);
      await _client.from('lesson_progress').upsert({
        'student_id': uid,
        'lesson_id': lessonId,
        'watched_seconds': watchedSeconds,
        'is_completed': isCompleted,
        'last_watched_at': DateTime.now().toIso8601String(),
      }, onConflict: 'student_id,lesson_id');
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.success(null);
    }
  }

  /// Retrieves student progress records across lessons.
  Future<ApiResult<List<LessonProgressModel>>> getStudentProgress(
    String studentId,
  ) async {
    try {
      final uid = _client.auth.currentUser?.id ??
          _client.auth.currentSession?.user.id ??
          studentId;
      if (uid.isEmpty) return const ApiResult.success([]);
      final data = await _client
          .from('lesson_progress')
          .select()
          .eq('student_id', uid);
      return ApiResult.success(
        data.map((e) => LessonProgressModel.fromJson(e)).toList(),
      );
    } catch (_) {
      return const ApiResult.success([]);
    }
  }
}
