import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
export 'admin_active_codes_generator_ext.dart';

class AdminActiveCodesRepo {
  final SupabaseClient _client;

  AdminActiveCodesRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  Future<ApiResult<List<Map<String, dynamic>>>> getActiveCodes({
    String? teacherId,
    String? courseId,
  }) async {
    try {
      var query = _client.from('activation_codes').select('''
            id, teacher_id, course_id, code, is_used, created_at,
            teachers(id, users(full_name, email), subjects(name_ar)),
            courses(id, title)
          ''').eq('is_used', false);

      if (teacherId != null && teacherId.isNotEmpty) query = query.eq('teacher_id', teacherId);
      if (courseId != null && courseId.isNotEmpty) query = query.eq('course_id', courseId);

      final data = await query.order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('[AdminActiveCodesRepo] getActiveCodes error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteCode(String codeId) async {
    try {
      await _client.from('activation_codes').delete().eq('id', codeId).eq('is_used', false);
      return const ApiResult.success(null);
    } catch (e) {
      debugPrint('[AdminActiveCodesRepo] deleteCode error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, users!inner(full_name, email), subjects(name_ar)
          ''').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getCourses(String teacherId) async {
    try {
      final data = await _client.from('courses').select('id, title').eq('teacher_id', teacherId).order('title');
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
