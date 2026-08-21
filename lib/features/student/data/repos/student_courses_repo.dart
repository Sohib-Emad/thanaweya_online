import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_discovery_repo.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_lessons_repo.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_my_courses_repo.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_subscribed_teachers_repo.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_subscription_repo.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_teacher_profile_repo.dart';

/// Facade that delegates to specialised sub-repos.
class StudentCoursesRepo {
  final StudentCoursesLessonsRepo lessons = StudentCoursesLessonsRepo();
  final StudentCoursesSubscriptionRepo subscription =
      StudentCoursesSubscriptionRepo();
  final StudentCoursesTeacherProfileRepo teacherProfile =
      StudentCoursesTeacherProfileRepo();
  final StudentCoursesDiscoveryRepo discovery =
      StudentCoursesDiscoveryRepo();
  final StudentCoursesMyCoursesRepo myCourses =
      StudentCoursesMyCoursesRepo();
  final StudentCoursesSubscribedTeachersRepo subscribedTeachers =
      StudentCoursesSubscribedTeachersRepo();

  final SupabaseClient _client = Supabase.instance.client;

  /// Delegates to [subscribedTeachers].
  Future<ApiResult<List<Map<String, dynamic>>>> getSubscribedTeachers(
    String studentId,
  ) => subscribedTeachers.getSubscribedTeachers(studentId);

  /// Delegates to [discovery].
  Future<ApiResult<List<CourseModel>>> getTeacherCourses(
    String teacherId,
  ) async {
    try {
      List<dynamic> data = [];
      try {
        data = await _client
            .from('courses')
            .select()
            .eq('teacher_id', teacherId)
            .order('order');
      } catch (e) {
        return ApiErrorHandler.handleException(e);
      }
      return ApiResult.success(
        data.map((e) => CourseModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Delegates to [discovery].
  Future<ApiResult<List<Map<String, dynamic>>>> getSubjects() =>
      discovery.getSubjects();

  /// Delegates to [discovery].
  Future<ApiResult<List<Map<String, dynamic>>>> getApprovedTeachers() =>
      discovery.getApprovedTeachers();

  /// Delegates to [myCourses].
  Future<ApiResult<List<Map<String, dynamic>>>> getMyCourses(
    String studentId,
  ) => myCourses.getMyCourses(studentId);

  /// Delegates to [discovery].
  Future<ApiResult<List<Map<String, dynamic>>>> getPopularCourses() =>
      discovery.popular.getPopularCourses();

  /// Single course with its teacher + subject info.
  Future<ApiResult<Map<String, dynamic>?>> getCourse(String courseId) async {
    final cleanId = courseId.trim();
    if (cleanId.isEmpty) return const ApiResult.success(null);
    try {
      Map<String, dynamic>? courseData;
      try {
        courseData = await _client
            .from('courses')
            .select()
            .eq('id', cleanId)
            .maybeSingle();
      } catch (e) {
        debugPrint('[StudentCoursesRepo] getCourse initial select error: $e');
      }

      if (courseData == null) {
        try {
          final list = await _client
              .from('courses')
              .select()
              .eq('id', cleanId)
              .limit(1);
          if (list.isNotEmpty) {
            courseData = Map<String, dynamic>.from(list.first);
          }
        } catch (e) {
          debugPrint('[StudentCoursesRepo] getCourse fallback error: $e');
        }
      }

      debugPrint('[StudentCoursesRepo] getCourse("$cleanId") -> courseData: $courseData');
      if (courseData == null) return const ApiResult.success(null);

      // Fetch lesson count safely
      int lessonCount = 0;
      try {
        final lessons = await _client
            .from('lessons')
            .select('id')
            .eq('course_id', cleanId);
        lessonCount = (lessons as List).length;
      } catch (_) {}

      final teacherId = courseData['teacher_id'] as String?;
      Map<String, dynamic>? teacherRow, userRow, subjectRow;
      if (teacherId != null && teacherId.isNotEmpty) {
        try {
          teacherRow = await _client
              .from('teachers')
              .select('id, subject_id, bio, stage')
              .eq('id', teacherId)
              .maybeSingle();
        } catch (_) {}
        try {
          userRow = await _client
              .from('users')
              .select('id, full_name, avatar_url')
              .eq('id', teacherId)
              .maybeSingle();
        } catch (_) {}
        final subjectId = teacherRow?['subject_id'] as String?;
        if (subjectId != null && subjectId.isNotEmpty) {
          try {
            subjectRow = await _client
                .from('subjects')
                .select('id, name_ar')
                .eq('id', subjectId)
                .maybeSingle();
          } catch (_) {}
        }
      }
      return ApiResult.success({
        ...courseData,
        'lessons': {'count': lessonCount},
        'teachers': {
          ...(teacherRow ?? {}),
          'users': userRow ?? {},
          'subjects': subjectRow ?? {},
        },
        'teacher_name': userRow?['full_name'] ?? 'مدرس',
        'subject_name': subjectRow?['name_ar'] ?? '',
      });
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
