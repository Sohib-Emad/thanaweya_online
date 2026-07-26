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

  Future<ApiResult<List<Map<String, dynamic>>>> getTeachersBySubject(
      String subjectId) async {
    try {
      final data = await _client.from('teachers').select('''
            id, stage, bio, approval_status, created_at,
            users!inner(id, full_name, avatar_url)
          ''').eq('subject_id', subjectId).eq('approval_status', 'approved');
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

  Future<ApiResult<void>> activateSubscription({
    required String studentId,
    required String teacherId,
    required String activationCode,
  }) async {
    try {
      final codeData = await _client
          .from('activation_codes')
          .select()
          .eq('code', activationCode)
          .eq('is_used', false)
          .eq('teacher_id', teacherId)
          .maybeSingle();

      if (codeData == null) {
        return const ApiResult.failure('كود التفعيل غير صحيح أو مستخدم بالفعل');
      }

      await _client.from('activation_codes').update({
        'is_used': true,
        'used_by': studentId,
        'used_at': DateTime.now().toIso8601String(),
      }).eq('id', codeData['id']);

      await _client.from('subscriptions').insert({
        'student_id': studentId,
        'teacher_id': teacherId,
        'activation_code_id': codeData['id'],
        'status': 'active',
      });

      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getSubscriptions(
      String studentId) async {
    try {
      final data = await _client.from('subscriptions').select('''
            id, status, starts_at, expires_at, created_at,
            teachers!inner(id, subject_id, stage,
              users!inner(id, full_name, avatar_url)
            )
          ''').eq('student_id', studentId).eq('status', 'active');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateStudentProfile({
    required String userId,
    required String fullName,
    required String phone,
  }) async {
    try {
      await _client.from('users').update({
        'full_name': fullName,
        'phone': phone,
      }).eq('id', userId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
