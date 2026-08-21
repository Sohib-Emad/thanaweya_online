import 'package:flutter/material.dart';
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
    final cleanId = courseId.trim();
    if (cleanId.isEmpty) return const ApiResult.success([]);
    try {
      final data = await _client
          .from('lessons')
          .select()
          .eq('course_id', cleanId)
          .order('order');
      return ApiResult.success(
        data.map((e) => LessonModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Updates or inserts student lesson progress without touching view_count.
  Future<ApiResult<void>> updateLessonProgress({
    required String studentId,
    required String lessonId,
    required int watchedSeconds,
    required bool isCompleted,
  }) async {
    final cleanLessonId = lessonId.trim();
    if (cleanLessonId.isEmpty) return const ApiResult.success(null);
    try {
      final uid = (_client.auth.currentUser?.id ?? studentId).trim();
      if (uid.isEmpty) return const ApiResult.success(null);
      // First try UPDATE (preserves view_count)
      final updated = await _client
          .from('lesson_progress')
          .update({
            'watched_seconds': watchedSeconds,
            'is_completed': isCompleted,
            'last_watched_at': DateTime.now().toIso8601String(),
          })
          .eq('student_id', uid)
          .eq('lesson_id', cleanLessonId)
          .select('id');
      // If no row was updated, INSERT a new record (view_count defaults to 0)
      if ((updated as List).isEmpty) {
        await _client.from('lesson_progress').insert({
          'student_id': uid,
          'lesson_id': cleanLessonId,
          'watched_seconds': watchedSeconds,
          'is_completed': isCompleted,
          'view_count': 0,
          'last_watched_at': DateTime.now().toIso8601String(),
        });
      }
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
      final uid = (_client.auth.currentUser?.id ??
              _client.auth.currentSession?.user.id ??
              studentId)
          .trim();
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

  /// Fetches exams linked to this course and student submissions.
  Future<ApiResult<Map<String, dynamic>>> getCourseLessonExams({
    required String courseId,
    required String studentId,
  }) async {
    final cleanCourseId = courseId.trim();
    if (cleanCourseId.isEmpty) {
      return const ApiResult.success({
        'exams': <Map<String, dynamic>>[],
        'submissions': <Map<String, dynamic>>[],
      });
    }
    try {
      final uid = (studentId.isNotEmpty
              ? studentId
              : (_client.auth.currentUser?.id ??
                  _client.auth.currentSession?.user.id ??
                  ''))
          .trim();

      List<Map<String, dynamic>> allExams = [];

      // 1. Get all lesson IDs for this course
      List<String> lessonIds = [];
      try {
        final lessonsRes = await _client
            .from('lessons')
            .select('id')
            .eq('course_id', cleanCourseId);
        lessonIds = (lessonsRes as List)
            .map((l) => l['id'] as String?)
            .whereType<String>()
            .toList();
      } catch (_) {}

      // 2. Fetch exams by course_id
      try {
        final courseExams = await _client
            .from('exams')
            .select(
                'id, title, course_id, lesson_id, passing_score, is_published, duration_minutes')
            .eq('course_id', cleanCourseId);
        for (final e in (courseExams as List)) {
          allExams.add(Map<String, dynamic>.from(e as Map));
        }
      } catch (e) {
        debugPrint('[getCourseLessonExams] error course exams: $e');
      }

      // 3. Also fetch exams by lesson_id in case course_id was not set
      if (lessonIds.isNotEmpty) {
        try {
          final lessonExams = await _client
              .from('exams')
              .select('id, title, course_id, lesson_id, passing_score, is_published, duration_minutes')
              .inFilter('lesson_id', lessonIds);
          for (final e in (lessonExams as List)) {
            final map = Map<String, dynamic>.from(e as Map);
            final exists = allExams.any((x) => x['id'] == map['id']);
            if (!exists) {
              allExams.add(map);
            }
          }
        } catch (e) {
          debugPrint('[getCourseLessonExams] error lesson exams: $e');
        }
      }

      // Filter out only explicitly unpublished exams (false)
      final validExams = allExams.where((e) {
        final pub = e['is_published'];
        return pub == null || pub == true;
      }).toList();

      final examIds = validExams
          .map((e) => e['id'] as String?)
          .whereType<String>()
          .toList();

      List<Map<String, dynamic>> submissionsData = [];
      if (examIds.isNotEmpty && uid.isNotEmpty) {
        try {
          final subs = await _client
              .from('exam_submissions')
              .select('id, exam_id, score, total_points, submitted_at')
              .eq('student_id', uid)
              .inFilter('exam_id', examIds);
          submissionsData = (subs as List)
              .map((s) => Map<String, dynamic>.from(s as Map))
              .toList();
        } catch (e) {
          debugPrint('[getCourseLessonExams] error submissions: $e');
        }
      }

      return ApiResult.success({
        'exams': validExams,
        'submissions': submissionsData,
      });
    } catch (e) {
      debugPrint('[getCourseLessonExams] general error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
