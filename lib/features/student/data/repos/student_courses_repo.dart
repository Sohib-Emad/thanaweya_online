import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';

class StudentCoursesRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getSubscribedTeachers(
    String studentId,
  ) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('teacher_id, status, starts_at, expires_at')
          .eq('student_id', studentId)
          .eq('status', 'active');

      if (subData.isEmpty) return const ApiResult.success([]);

      final teacherIds = subData.map((e) => e['teacher_id'] as String).toList();

      final teachersData = await _client
          .from('teachers')
          .select('id, subject_id, stage, bio')
          .inFilter('id', teacherIds);

      final usersData = await _client
          .from('users')
          .select('id, full_name, avatar_url')
          .inFilter('id', teacherIds);

      final usersMap = {for (final u in usersData) u['id'] as String: u};

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
          'teachers': {...teacher, 'users': user},
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<CourseModel>>> getTeacherCourses(
    String teacherId,
  ) async {
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
    String studentId,
  ) async {
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
    String studentId,
  ) async {
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
            id, teacher_id, title, description, cover_image_url,
            price, intro_video_url, intro_video_source_type,
            is_published, "order", created_at, updated_at,
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

      // Fetch all lessons for these courses to count them and map progress
      final courseIds = coursesData.map((e) => e['id'] as String).toList();
      var lessonsData = <Map<String, dynamic>>[];
      var progressData = <Map<String, dynamic>>[];

      if (courseIds.isNotEmpty) {
        lessonsData = await _client
            .from('lessons')
            .select('id, course_id')
            .inFilter('course_id', courseIds);

        final lessonIds = lessonsData.map((e) => e['id'] as String).toList();
        if (lessonIds.isNotEmpty) {
          progressData = await _client
              .from('lesson_progress')
              .select('lesson_id, is_completed')
              .eq('student_id', studentId)
              .inFilter('lesson_id', lessonIds)
              .eq('is_completed', true);
        }
      }

      final completedLessonIds = progressData
          .map((e) => e['lesson_id'] as String)
          .toSet();

      final courseLessonsMap = <String, List<String>>{};
      for (final lesson in lessonsData) {
        final cId = lesson['course_id'] as String;
        final lId = lesson['id'] as String;
        courseLessonsMap.putIfAbsent(cId, () => []).add(lId);
      }

      final usersMap = {for (final u in userRows) u['id'] as String: u};
      final teachersMap = {for (final t in teacherRows) t['id'] as String: t};
      final subjectsMap = {for (final s in subjectRows) s['id'] as String: s};

      final result = <Map<String, dynamic>>[];
      for (final course in coursesData) {
        final courseId = course['id'] as String;
        final teacherId = course['teacher_id'] as String;
        final teacher = teachersMap[teacherId] ?? {};
        final subjectId = teacher['subject_id'];

        final courseLessonIds = courseLessonsMap[courseId] ?? [];
        final totalCount = courseLessonIds.length;
        final completedCount = courseLessonIds
            .where((lId) => completedLessonIds.contains(lId))
            .length;
        final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

        result.add({
          ...course,
          'teacher_name':
              (usersMap[teacherId]?['full_name'] as String?) ?? 'مدرس',
          'subject_name': subjectId != null
              ? (subjectsMap[subjectId]?['name_ar'] as String?) ?? ''
              : '',
          'subject_id': subjectId,
          'stage': teacher['stage'],
          'totalCount': totalCount,
          'completedCount': completedCount,
          'progress': progress,
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// All published courses of approved teachers, enriched with teacher name,
  /// subject name and lesson counts. Not restricted to the student's
  /// subscriptions.
  Future<ApiResult<List<Map<String, dynamic>>>> getPopularCourses() async {
    try {
      final teacherRows = await _client
          .from('teachers')
          .select('id, subject_id, stage')
          .eq('approval_status', 'approved');

      if (teacherRows.isEmpty) return const ApiResult.success([]);

      final teacherIds = teacherRows.map((t) => t['id'] as String).toList();

      final coursesData = await _client
          .from('courses')
          .select('''
            id, teacher_id, title, description, cover_image_url,
            price, intro_video_url, intro_video_source_type,
            is_published, "order", created_at, updated_at,
            lessons(count)
          ''')
          .inFilter('teacher_id', teacherIds)
          .eq('is_published', true)
          .order('order');

      if (coursesData.isEmpty) return const ApiResult.success([]);

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

      final usersMap = {for (final u in userRows) u['id'] as String: u};
      final teachersMap = {for (final t in teacherRows) t['id'] as String: t};
      final subjectsMap = {for (final s in subjectRows) s['id'] as String: s};

      final result = <Map<String, dynamic>>[];
      for (final course in coursesData) {
        final teacherId = course['teacher_id'] as String;
        final teacher = teachersMap[teacherId] ?? {};
        final subjectId = teacher['subject_id'];
        result.add({
          ...course,
          'teacher_name':
              (usersMap[teacherId]?['full_name'] as String?) ?? 'مدرس',
          'subject_name': subjectId != null
              ? (subjectsMap[subjectId]?['name_ar'] as String?) ?? ''
              : '',
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
            id, teacher_id, title, description, cover_image_url,
            price, intro_video_url, intro_video_source_type,
            is_published, "order", created_at, updated_at,
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

  /// Checks if a student is subscribed to a course or teacher.
  Future<ApiResult<bool>> checkIsSubscribed({
    required String studentId,
    String? courseId,
    String? teacherId,
  }) async {
    try {
      if (studentId.isEmpty) return const ApiResult.success(false);

      String? targetTeacherId = teacherId;
      if ((targetTeacherId == null || targetTeacherId.isEmpty) &&
          courseId != null &&
          courseId.isNotEmpty) {
        final courseRes = await _client
            .from('courses')
            .select('teacher_id')
            .eq('id', courseId)
            .maybeSingle();
        targetTeacherId = courseRes?['teacher_id'] as String?;
      }

      if (targetTeacherId == null || targetTeacherId.isEmpty) {
        return const ApiResult.success(false);
      }

      final subRes = await _client
          .from('subscriptions')
          .select('id, expires_at')
          .eq('student_id', studentId)
          .eq('teacher_id', targetTeacherId)
          .eq('status', 'active')
          .maybeSingle();

      if (subRes == null) return const ApiResult.success(false);

      final expiresAtStr = subRes['expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.tryParse(expiresAtStr);
        if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
          return const ApiResult.success(false);
        }
      }

      return const ApiResult.success(true);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getTeacherProfile(
    String teacherId,
  ) async {
    try {
      final data = await _client
          .from('teachers')
          .select('''
            id, stage, bio, approval_status, created_at,
            teaching_system, governorate, teaching_mode, stages, baccalaureate_tracks,
            users!inner(id, full_name, avatar_url, phone),
            subjects(id, name_ar)
          ''')
          .eq('id', teacherId)
          .single();
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
