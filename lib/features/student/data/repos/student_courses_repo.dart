import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';

class StudentCoursesRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getSubscribedTeachers(
      String studentId) async {
    try {
      final data = await _client.from('subscriptions').select('''
            teachers!inner(id, subject_id, stage, bio,
              users!inner(id, full_name, avatar_url)
            )
          ''').eq('student_id', studentId).eq('status', 'active');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<CourseModel>>> getTeacherCourses(
      String teacherId) async {
    try {
      final data = await _client
          .from('courses')
          .select()
          .eq('teacher_id', teacherId)
          .eq('is_published', true)
          .order('order');
      return ApiResult.success(
        data.map((e) => CourseModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<LessonModel>>> getCourseLessons(
      String courseId) async {
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

  Future<ApiResult<void>> updateLessonProgress({
    required String studentId,
    required String lessonId,
    required int watchedSeconds,
    required bool isCompleted,
  }) async {
    try {
      await _client.from('lesson_progress').upsert({
        'student_id': studentId,
        'lesson_id': lessonId,
        'watched_seconds': watchedSeconds,
        'is_completed': isCompleted,
        'last_watched_at': DateTime.now().toIso8601String(),
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<LessonProgressModel>>> getStudentProgress(
      String studentId) async {
    try {
      final data = await _client
          .from('lesson_progress')
          .select()
          .eq('student_id', studentId);
      return ApiResult.success(
        data.map((e) => LessonProgressModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
