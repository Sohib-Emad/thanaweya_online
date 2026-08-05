import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class TeacherStudentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getStudents(
      String teacherId) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('id, student_id, status, created_at')
          .eq('teacher_id', teacherId);

      if (subData.isEmpty) return const ApiResult.success([]);

      final studentIds = subData
          .map((e) => e['student_id'] as String?)
          .whereType<String>()
          .toList();

      if (studentIds.isEmpty) return const ApiResult.success([]);

      final studentsData = await _client
          .from('students')
          .select('id, grade_level, parent_phone, created_at')
          .inFilter('id', studentIds);

      final usersData = await _client
          .from('users')
          .select('id, full_name, email, phone')
          .inFilter('id', studentIds);

      final usersMap = {
        for (final u in usersData)
          if (u['id'] != null) (u['id'] as String? ?? ''): u
      };
      final studentsMap = {
        for (final s in studentsData)
          if (s['id'] != null) (s['id'] as String? ?? ''): s
      };

      final result = <Map<String, dynamic>>[];
      for (final sub in subData) {
        final studentId = sub['student_id'] as String?;
        if (studentId == null) continue;
        result.add({
          ...sub,
          'students': studentsMap[studentId] ?? {},
          'users': usersMap[studentId] ?? {},
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getStudentDetail(
      String studentId) async {
    try {
      final data = await _client.from('students').select('''
            id, grade_level, parent_phone, created_at,
            users!inner(id, full_name, email, phone)
          ''').eq('id', studentId).single();
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentProgress(
      String teacherId) async {
    try {
      final data = await _client.from('lesson_progress').select('''
            id, student_id, lesson_id, is_completed, watched_seconds, last_watched_at,
            lessons!inner(id, title, course_id,
              courses!inner(id, title, teacher_id)
            )
          ''').eq('lessons.courses.teacher_id', teacherId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentProgressForStudent(
    String teacherId,
    String studentId,
  ) async {
    try {
      final data = await _client.from('lesson_progress').select('''
            id, student_id, lesson_id, is_completed, watched_seconds, last_watched_at,
            lessons!inner(id, title, course_id,
              courses!inner(id, title, teacher_id)
            )
          ''')
          .eq('student_id', studentId)
          .eq('lessons.courses.teacher_id', teacherId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentSubscriptions(
      String teacherId, String studentId) async {
    try {
      final data = await _client
          .from('subscriptions')
          .select('id, status, starts_at, expires_at, created_at')
          .eq('teacher_id', teacherId)
          .eq('student_id', studentId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
