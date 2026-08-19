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
    try {
      if (courseId.trim().isEmpty) return const ApiResult.success(null);
      final courseData = await _client
          .from('courses')
          .select(
            'id, teacher_id, title, description, cover_image_url, price, '
            'intro_video_url, intro_video_source_type, is_published, '
            '"order", created_at, updated_at, lessons(count)',
          )
          .eq('id', courseId)
          .maybeSingle();
      if (courseData == null) return const ApiResult.success(null);
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
