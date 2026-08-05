import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

class TeacherCoursesRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<CourseModel>>> getCourses(String teacherId) async {
    try {
      final data = await _client
          .from('courses')
          .select()
          .eq('teacher_id', teacherId)
          .order('order');
      return ApiResult.success(
        data.map((e) => CourseModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<CourseModel>> createCourse({
    required String teacherId,
    required String title,
    String? description,
    String? coverImageUrl,
    bool isPublished = false,
  }) async {
    try {
      final data = await _client
          .from('courses')
          .insert({
            'teacher_id': teacherId,
            'title': title,
            'description': description,
            'cover_image_url': coverImageUrl,
            'is_published': isPublished,
          })
          .select()
          .single();
      return ApiResult.success(CourseModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateCourse({
    required String courseId,
    required String title,
    String? description,
    String? coverImageUrl,
    bool? isPublished,
  }) async {
    try {
      final updates = <String, dynamic>{
        'title': title,
        'description': description,
      };
      if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;
      if (isPublished != null) updates['is_published'] = isPublished;

      await _client.from('courses').update(updates).eq('id', courseId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteCourse(String courseId) async {
    try {
      await _client.from('courses').delete().eq('id', courseId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<LessonModel>>> getLessons(String courseId) async {
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

  Future<ApiResult<LessonModel>> addLesson({
    required String courseId,
    required String title,
    String? description,
    required String videoSourceType,
    required String videoUrlOrId,
    bool isFreePreview = false,
  }) async {
    try {
      final data = await _client
          .from('lessons')
          .insert({
            'course_id': courseId,
            'title': title,
            'description': description,
            'video_source_type': videoSourceType,
            'video_url_or_id': videoUrlOrId,
            'is_free_preview': isFreePreview,
          })
          .select()
          .single();
      return ApiResult.success(LessonModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateLesson({
    required String lessonId,
    required String title,
    String? description,
    String? videoUrlOrId,
    bool? isFreePreview,
  }) async {
    try {
      final updates = <String, dynamic>{
        'title': title,
        'description': description,
      };
      if (videoUrlOrId != null) updates['video_url_or_id'] = videoUrlOrId;
      if (isFreePreview != null) updates['is_free_preview'] = isFreePreview;

      await _client.from('lessons').update(updates).eq('id', lessonId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteLesson(String lessonId) async {
    try {
      await _client.from('lessons').delete().eq('id', lessonId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<Map<String, int>>> getCourseLessonCounts(
      String teacherId) async {
    try {
      final data = await _client
          .from('lessons')
          .select('course_id, courses!inner(teacher_id)')
          .eq('courses.teacher_id', teacherId);
      final counts = <String, int>{};
      for (final row in data) {
        final courseId = row['course_id'] as String?;
        if (courseId == null) continue;
        counts[courseId] = (counts[courseId] ?? 0) + 1;
      }
      return ApiResult.success(counts);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
