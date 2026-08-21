import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_lesson_exams_repo.dart';

/// View tracking and document operations for student lessons.
class StudentCoursesLessonsDetailRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final StudentCoursesLessonExamsRepo examsRepo = StudentCoursesLessonExamsRepo();

  /// The student's video view usage for one lesson.
  Future<ApiResult<Map<String, dynamic>?>> getLessonViewStatus({
    required String studentId,
    required String lessonId,
  }) async {
    final cleanLessonId = lessonId.trim();
    if (cleanLessonId.isEmpty) {
      return const ApiResult.success({'maxViews': 3, 'viewCount': 0});
    }
    try {
      final uid = (_client.auth.currentUser?.id ??
              _client.auth.currentSession?.user.id ??
              studentId)
          .trim();
      int maxViews = 3;
      try {
        final lesson = await _client
            .from('lessons')
            .select('max_views')
            .eq('id', cleanLessonId)
            .maybeSingle();
        if (lesson != null && lesson['max_views'] != null) {
          final mv = (lesson['max_views'] as num).toInt();
          if (mv > 0) maxViews = mv;
        }
      } catch (_) {}

      int viewCount = 0;
      if (uid.isNotEmpty) {
        try {
          final progress = await _client
              .from('lesson_progress')
              .select('view_count')
              .eq('student_id', uid)
              .eq('lesson_id', lessonId)
              .maybeSingle();
          if (progress != null && progress['view_count'] != null) {
            viewCount = (progress['view_count'] as num).toInt();
          }
        } catch (_) {}
      }
      return ApiResult.success({'maxViews': maxViews, 'viewCount': viewCount});
    } catch (_) {
      return const ApiResult.success({'maxViews': 3, 'viewCount': 0});
    }
  }

  /// Atomically bumps the student's view count for a lesson.
  Future<ApiResult<int>> incrementLessonView({
    required String studentId,
    required String lessonId,
  }) async {
    final uid = _client.auth.currentUser?.id ?? studentId;
    if (uid.isEmpty) return const ApiResult.success(1);
    try {
      try {
        final res = await _client.rpc(
          'increment_lesson_view',
          params: {'p_student_id': uid, 'p_lesson_id': lessonId},
        );
        if (res != null) {
          return ApiResult.success((res as num).toInt());
        }
      } catch (_) {}
      return await _incrementViewFallback(uid, lessonId);
    } catch (_) {
      return const ApiResult.success(1);
    }
  }

  Future<ApiResult<int>> _incrementViewFallback(
    String uid,
    String lessonId,
  ) async {
    try {
      final current = await _client
          .from('lesson_progress')
          .select('view_count')
          .eq('student_id', uid)
          .eq('lesson_id', lessonId)
          .maybeSingle();
      final currentCount = (current?['view_count'] as num?)?.toInt() ?? 0;
      final newCount = currentCount + 1;

      if (current != null) {
        await _client
            .from('lesson_progress')
            .update({
              'view_count': newCount,
              'last_watched_at': DateTime.now().toIso8601String(),
            })
            .eq('student_id', uid)
            .eq('lesson_id', lessonId);
      } else {
        await _client.from('lesson_progress').insert({
          'student_id': uid,
          'lesson_id': lessonId,
          'view_count': newCount,
          'watched_seconds': 0,
          'is_completed': false,
          'last_watched_at': DateTime.now().toIso8601String(),
        });
      }
      return ApiResult.success(newCount);
    } catch (_) {
      return const ApiResult.success(1);
    }
  }

  /// The documents published for a lesson.
  Future<ApiResult<List<Map<String, dynamic>>>> getLessonDocuments(
    String lessonId,
  ) async {
    final cleanId = lessonId.trim();
    if (cleanId.isEmpty) return const ApiResult.success([]);
    try {
      final data = await _client
          .from('lesson_documents')
          .select('id, title, file_url, file_type, created_at')
          .eq('lesson_id', cleanId)
          .order('created_at');
      return ApiResult.success(
        data.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
