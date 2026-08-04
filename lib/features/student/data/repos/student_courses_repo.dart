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
      final subData = await _client
          .from('subscriptions')
          .select('teacher_id, status, starts_at, expires_at')
          .eq('student_id', studentId)
          .eq('status', 'active');

      if (subData.isEmpty) return const ApiResult.success([]);

      final teacherIds =
          subData.map((e) => e['teacher_id'] as String).toList();

      final teachersData = await _client
          .from('teachers')
          .select('id, subject_id, stage, bio')
          .inFilter('id', teacherIds);

      final usersData = await _client
          .from('users')
          .select('id, full_name, avatar_url')
          .inFilter('id', teacherIds);

      final usersMap = {
        for (final u in usersData) u['id'] as String: u,
      };

      final result = <Map<String, dynamic>>[];
      for (final sub in subData) {
        final teacherId = sub['teacher_id'] as String;
        final teacher = teachersData.firstWhere(
          (t) => t['id'] == teacherId,
          orElse: () => {},
        );
        final user = usersMap[teacherId] ?? {};
        result.add({
          ...sub,
          'teachers': {
            ...teacher,
            'users': user,
          },
        });
      }

      return ApiResult.success(result);
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

  Future<ApiResult<List<Map<String, dynamic>>>> getSubjects() async {
    try {
      final data = await _client
          .from('subjects')
          .select('id, name_ar, name_en, icon_name')
          .eq('is_active', true)
          .order('display_order');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getApprovedTeachers() async {
    try {
      final data = await _client
          .from('teachers')
          .select('''
            id, stage, bio, approval_status, created_at,
            users!inner(id, full_name, avatar_url),
            subjects(id, name_ar)
          ''')
          .eq('approval_status', 'approved')
          .order('created_at');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Courses of the teachers the student is subscribed to,
  /// enriched with teacher name, subject name and lesson counts.
  Future<ApiResult<List<Map<String, dynamic>>>> getMyCourses(
      String studentId) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('teacher_id')
          .eq('student_id', studentId)
          .eq('status', 'active');

      if (subData.isEmpty) return const ApiResult.success([]);

      final teacherIds = subData
          .map((e) => e['teacher_id'] as String)
          .toSet()
          .toList();

      final coursesData = await _client
          .from('courses')
          .select('''
            id, teacher_id, title, description, cover_image_url, is_published, "order", created_at, updated_at,
            lessons(count)
          ''')
          .inFilter('teacher_id', teacherIds)
          .eq('is_published', true)
          .order('order');

      final teacherRows = await _client
          .from('teachers')
          .select('id, subject_id, stage, bio')
          .inFilter('id', teacherIds);

      final userRows = await _client
          .from('users')
          .select('id, full_name, avatar_url')
          .inFilter('id', teacherIds);

      final subjectIds = teacherRows
          .map((t) => t['subject_id'] as String)
          .toSet()
          .toList();

      var subjectRows = <Map<String, dynamic>>[];
      if (subjectIds.isNotEmpty) {
        subjectRows = await _client
            .from('subjects')
            .select('id, name_ar')
            .inFilter('id', subjectIds);
      }

      final usersMap = {
        for (final u in userRows) u['id'] as String: u,
      };
      final teachersMap = {
        for (final t in teacherRows) t['id'] as String: t,
      };
      final subjectsMap = {
        for (final s in subjectRows) s['id'] as String: s,
      };

      final result = <Map<String, dynamic>>[];
      for (final course in coursesData) {
        final teacherId = course['teacher_id'] as String;
        final teacher = teachersMap[teacherId] ?? {};
        final subjectId = teacher['subject_id'];
        result.add({
          ...course,
          'teacher_name':
              (usersMap[teacherId]?['full_name'] as String?) ?? 'مدرس',
          'subject_name':
              subjectId != null ? (subjectsMap[subjectId]?['name_ar'] as String?) ?? '' : '',
          'subject_id': subjectId,
          'stage': teacher['stage'],
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Single published course with its teacher + subject info.
  Future<ApiResult<Map<String, dynamic>?>> getCourse(String courseId) async {
    try {
      final data = await _client
          .from('courses')
          .select('''
            id, teacher_id, title, description, cover_image_url, is_published, "order", created_at, updated_at,
            teachers(id, subject_id, bio,
              users(id, full_name, avatar_url),
              subjects(id, name_ar)
            ),
            lessons(count)
          ''')
          .eq('id', courseId)
          .eq('is_published', true)
          .maybeSingle();
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
