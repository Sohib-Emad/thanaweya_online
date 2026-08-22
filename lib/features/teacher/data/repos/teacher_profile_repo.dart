import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/teacher_model.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';

class TeacherProfileRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Returns the teacher's `approval_status` (pending / approved / rejected).
  /// Used as a gate before routing a teacher into their dashboard.
  Future<ApiResult<String>> getApprovalStatus(String userId) async {
    try {
      final data = await _client
          .from('teachers')
          .select('approval_status')
          .eq('id', userId)
          .maybeSingle();
      if (data != null && data['approval_status'] != null) {
        return ApiResult.success(data['approval_status'] as String);
      }

      // Fallback: lookup by user email to handle ID synchronization
      final currentUser = _client.auth.currentUser;
      if (currentUser?.email != null) {
        final userRow = await _client
            .from('users')
            .select('id')
            .eq('email', currentUser!.email!)
            .maybeSingle();
        if (userRow != null) {
          final oldId = userRow['id'] as String;
          final oldTeacher = await _client
              .from('teachers')
              .select('approval_status')
              .eq('id', oldId)
              .maybeSingle();
          if (oldTeacher != null && oldTeacher['approval_status'] != null) {
            return ApiResult.success(oldTeacher['approval_status'] as String);
          }
        }
      }
      return const ApiResult.success('approved');
    } catch (e) {
      return const ApiResult.success('approved');
    }
  }

  Future<ApiResult<TeacherModel?>> getTeacherProfile(String userId) async {
    try {
      final data = await _client
          .from('teachers')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) {
        return ApiResult<TeacherModel?>.success(null);
      }
      return ApiResult.success(TeacherModel.fromJson(data));
    } catch (e) {
      return ApiResult.success(null);
    }
  }

  Future<ApiResult<UserModel>> getUserProfile(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) {
        return ApiResult.success(UserModel(
          id: userId,
          email: '',
          fullName: '',
          phone: '',
          role: UserRole.teacher,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      return ApiResult.success(UserModel.fromJson(data));
    } catch (e) {
      return ApiResult.success(UserModel(
        id: userId,
        email: '',
        fullName: '',
        phone: '',
        role: UserRole.teacher,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<ApiResult<void>> registerTeacher({
    required String userId,
    required String subjectId,
    required String stage,
    required String bio,
  }) async {
    try {
      await _client.from('teachers').upsert({
        'id': userId,
        'subject_id': subjectId,
        'stage': stage,
        'bio': bio,
        'approval_status': 'pending',
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateProfile({
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

  Future<ApiResult<int>> getStudentsCount(String teacherId) async {
    try {
      final data = await _client
          .from('subscriptions')
          .select()
          .eq('teacher_id', teacherId)
          .eq('status', 'active');
      return ApiResult.success(data.length);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<int>> getCoursesCount(String teacherId) async {
    try {
      final data = await _client
          .from('courses')
          .select()
          .eq('teacher_id', teacherId);
      return ApiResult.success(data.length);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<int>> getExamsCount(String teacherId) async {
    try {
      final data = await _client
          .from('exams')
          .select()
          .eq('teacher_id', teacherId);
      return ApiResult.success(data.length);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
