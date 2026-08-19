import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class StudentOnboardingRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getSubjects() async {
    try {
      final data = await _client
          .from('subjects')
          .select()
          .eq('is_active', true)
          .order('display_order');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getTeachers() async {
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

  Future<ApiResult<void>> registerStudent({
    required String userId,
    required String gradeLevel,
    required String parentPhone,
  }) async {
    try {
      await _client.from('students').upsert({
        'id': userId,
        'grade_level': gradeLevel,
        'parent_phone': parentPhone,
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getSubscriptions(
    String studentId,
  ) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('id, teacher_id, status, starts_at, expires_at, created_at')
          .eq('student_id', studentId)
          .eq('status', 'active');

      if (subData.isEmpty) return const ApiResult.success([]);

      final teacherIds = subData.map((e) => e['teacher_id'] as String).toList();

      final teachersData = await _client
          .from('teachers')
          .select('id, subject_id, stage')
          .inFilter('id', teacherIds);

      final usersData = await _client
          .from('users')
          .select('id, full_name, avatar_url')
          .inFilter('id', teacherIds);

      final usersMap = {for (final u in usersData) u['id'] as String: u};
      final teachersMap = {for (final t in teachersData) t['id'] as String: t};

      final result = <Map<String, dynamic>>[];
      for (final sub in subData) {
        final teacherId = sub['teacher_id'] as String;
        result.add({
          ...sub,
          'teachers': {
            ...?teachersMap[teacherId],
            'users': usersMap[teacherId],
          },
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateStudentProfile({
    required String userId,
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'full_name': fullName,
        'phone': phone,
      };
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updates['avatar_url'] = avatarUrl;
      }

      await _client
          .from('users')
          .update(updates)
          .eq('id', userId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
