import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_lessons_documents_repo.dart';

/// Lesson CRUD, view resets, and document operations.
class TeacherCoursesLessonsRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final TeacherCoursesLessonsDocumentsRepo documents =
      TeacherCoursesLessonsDocumentsRepo();

  /// Fetches lessons for a course ordered by "order".
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

  /// Adds a lesson with automatic video_source_type fallback.
  Future<ApiResult<LessonModel>> addLesson({
    required String courseId,
    required String title,
    String? description,
    required String videoSourceType,
    required String videoUrlOrId,
    bool isFreePreview = false,
  }) async {
    final payload = <String, dynamic>{
      'course_id': courseId,
      'title': title,
      'description': description,
      'video_source_type': videoSourceType,
      'video_url_or_id': videoUrlOrId,
      'is_free_preview': isFreePreview,
    };
    try {
      final data =
          await _client.from('lessons').insert(payload).select().single();
      return ApiResult.success(LessonModel.fromJson(data));
    } catch (e) {
      if (_isVideoSourceError(e)) {
        try {
          payload['video_source_type'] = 'youtube';
          final data =
              await _client.from('lessons').insert(payload).select().single();
          return ApiResult.success(LessonModel.fromJson(data));
        } catch (e2) {
          return ApiErrorHandler.handleException(e2);
        }
      }
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Updates a lesson's metadata.
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

  /// Deletes a lesson by id.
  Future<ApiResult<void>> deleteLesson(String lessonId) async {
    try {
      await _client.from('lessons').delete().eq('id', lessonId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Re-opens a lesson's video for all students by resetting view counts.
  Future<ApiResult<void>> resetLessonViews(String lessonId) async {
    try {
      await _client
          .from('lesson_progress')
          .update({'view_count': 0})
          .eq('lesson_id', lessonId);
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.success(null);
    }
  }

  /// Returns lesson counts grouped by course for a teacher.
  Future<ApiResult<Map<String, int>>> getCourseLessonCounts(
    String teacherId,
  ) async {
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

  bool _isVideoSourceError(Object e) {
    final str = e.toString().toLowerCase();
    return str.contains('video_source') || str.contains('22p02');
  }
}
