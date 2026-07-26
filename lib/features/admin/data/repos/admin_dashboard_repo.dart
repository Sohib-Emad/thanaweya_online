import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminDashboardRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<Map<String, int>>> getDashboardStats() async {
    try {
      final teachers = await _client.from('teachers').select('id');
      final students = await _client.from('students').select('id');
      final courses = await _client.from('courses').select('id');
      final pendingRequests = await _client
          .from('teachers')
          .select('id')
          .eq('approval_status', 'pending');

      return ApiResult.success({
        'total_teachers': teachers.length,
        'total_students': students.length,
        'total_courses': courses.length,
        'pending_requests': pendingRequests.length,
      });
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getRecentTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, approval_status, created_at,
            users!inner(full_name, email),
            subjects!inner(name_ar)
          ''').order('created_at', ascending: false).limit(10);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getRecentStudents() async {
    try {
      final data = await _client.from('students').select('''
            id, grade_level, created_at,
            users!inner(full_name, email)
          ''').order('created_at', ascending: false).limit(10);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
