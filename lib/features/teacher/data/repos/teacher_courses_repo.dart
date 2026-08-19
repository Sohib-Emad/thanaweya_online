import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_lessons_repo.dart';

/// Facade that delegates lesson operations to [TeacherCoursesLessonsRepo].
class TeacherCoursesRepo {
  final TeacherCoursesLessonsRepo lessonsRepo = TeacherCoursesLessonsRepo();

  final SupabaseClient _client = Supabase.instance.client;

  /// Lists courses for a teacher, auto-publishing any unpublished ones.
  Future<ApiResult<List<CourseModel>>> getCourses(String teacherId) async {
    try {
      try {
        await _client
            .from('courses')
            .update({'is_published': true})
            .eq('teacher_id', teacherId)
            .eq('is_published', false);
      } catch (_) {}
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

  /// Creates a new course with automatic video_source_type fallback.
  Future<ApiResult<CourseModel>> createCourse({
    required String teacherId,
    required String title,
    String? description,
    String? coverImageUrl,
    double? price,
    String? introVideoUrl,
    String? introVideoSourceType,
    bool isPublished = true,
  }) async {
    final payload = <String, dynamic>{
      'teacher_id': teacherId,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'price': price,
      'intro_video_url': introVideoUrl,
      'intro_video_source_type': introVideoSourceType ?? 'youtube',
      'is_published': isPublished,
    };
    try {
      final data =
          await _client.from('courses').insert(payload).select().single();
      return ApiResult.success(CourseModel.fromJson(data));
    } catch (e) {
      if (_isVideoSourceError(e)) {
        try {
          payload['intro_video_source_type'] = 'youtube';
          final data =
              await _client.from('courses').insert(payload).select().single();
          return ApiResult.success(CourseModel.fromJson(data));
        } catch (e2) {
          return ApiErrorHandler.handleException(e2);
        }
      }
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Updates an existing course.
  Future<ApiResult<void>> updateCourse({
    required String courseId,
    required String title,
    String? description,
    String? coverImageUrl,
    double? price,
    String? introVideoUrl,
    String? introVideoSourceType,
    bool? clearPrice,
    bool? clearIntroVideo,
    bool? isPublished,
  }) async {
    try {
      final updates = <String, dynamic>{
        'title': title,
        'description': description,
      };
      if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;
      if (clearPrice == true) {
        updates['price'] = null;
      } else if (price != null) {
        updates['price'] = price;
      }
      if (clearIntroVideo == true) {
        updates['intro_video_url'] = null;
        updates['intro_video_source_type'] = null;
      } else if (introVideoUrl != null) {
        updates['intro_video_url'] = introVideoUrl;
        if (introVideoSourceType != null) {
          updates['intro_video_source_type'] = introVideoSourceType;
        }
      }
      if (isPublished != null) updates['is_published'] = isPublished;
      try {
        await _client.from('courses').update(updates).eq('id', courseId);
      } catch (e) {
        if (_isVideoSourceError(e)) {
          updates['intro_video_source_type'] = 'youtube';
          await _client.from('courses').update(updates).eq('id', courseId);
        } else {
          rethrow;
        }
      }
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes a course by id.
  Future<ApiResult<void>> deleteCourse(String courseId) async {
    try {
      await _client.from('courses').delete().eq('id', courseId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Delegates to lessons sub-repo.
  Future<ApiResult<void>> resetLessonViews(String lessonId) =>
      lessonsRepo.resetLessonViews(lessonId);

  bool _isVideoSourceError(Object e) {
    final str = e.toString().toLowerCase();
    return str.contains('video_source') || str.contains('22p02');
  }
}
