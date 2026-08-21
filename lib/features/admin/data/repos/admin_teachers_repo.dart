import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminTeachersRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getPendingTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, stage, bio, approval_status, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url,
            payment_receipt_url, selected_plan, payment_method, subscription_amount, requires_renewal, created_at,
            users!inner(id, full_name, email, phone, plain_password),
            subjects(id, name_ar)
          ''').eq('approval_status', 'pending').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      try {
        final data = await _client.from('teachers').select('''
              id, stage, bio, approval_status, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url,
              payment_receipt_url, selected_plan, payment_method, subscription_amount, created_at,
              users!inner(id, full_name, email, phone),
              subjects(id, name_ar)
            ''').eq('approval_status', 'pending').order('created_at', ascending: false);
        return ApiResult.success(List<Map<String, dynamic>>.from(data));
      } catch (err) {
        return ApiErrorHandler.handleException(err);
      }
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getAllTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, stage, bio, approval_status, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url,
            payment_receipt_url, selected_plan, payment_method, subscription_amount, requires_renewal, rejection_reason, created_at,
            users!inner(id, full_name, email, phone, plain_password),
            subjects(id, name_ar)
          ''').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      try {
        final data = await _client.from('teachers').select('''
              id, stage, bio, approval_status, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url,
              payment_receipt_url, selected_plan, payment_method, subscription_amount, rejection_reason, created_at,
              users!inner(id, full_name, email, phone),
              subjects(id, name_ar)
            ''').order('created_at', ascending: false);
        return ApiResult.success(List<Map<String, dynamic>>.from(data));
      } catch (err) {
        return ApiErrorHandler.handleException(err);
      }
    }
  }

  /// Sets or updates a teacher's password directly from the Admin panel.
  Future<ApiResult<void>> updateUserPassword(
    String userId,
    String newPassword,
  ) async {
    try {
      final res = await _client.rpc('admin_set_user_password', params: {
        'p_user_id': userId,
        'p_new_password': newPassword,
      });
      final map = res as Map<String, dynamic>?;
      if (map?['ok'] == true) {
        return const ApiResult.success(null);
      }
      return ApiResult.failure(
          map?['error']?.toString() ?? 'تعذر تغيير كلمة المرور');
    } catch (_) {
      try {
        await _client
            .from('users')
            .update({'plain_password': newPassword}).eq('id', userId);
        await _client
            .from('teachers')
            .update({'plain_password': newPassword}).eq('id', userId);
        return const ApiResult.success(null);
      } catch (e) {
        return ApiErrorHandler.handleException(e);
      }
    }
  }

  Future<ApiResult<void>> approveTeacher(String teacherId) async {
    try {
      await _client
          .from('teachers')
          .update({'approval_status': 'approved'}).eq('id', teacherId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> rejectTeacher(
      String teacherId, String reason) async {
    try {
      await _client.from('teachers').update({
        'approval_status': 'rejected',
        'rejection_reason': reason,
      }).eq('id', teacherId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> toggleRenewalAlert(
      String teacherId, bool requiresRenewal) async {
    try {
      await _client.from('teachers').update({
        'requires_renewal': requiresRenewal,
      }).eq('id', teacherId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> toggleBanTeacher(
      String teacherId, bool isBanned, {String? reason}) async {
    try {
      await _client.from('teachers').update({
        'approval_status': isBanned ? 'banned' : 'approved',
        'rejection_reason': isBanned ? (reason ?? 'تم حظر الحساب من قبل الإدارة') : null,
      }).eq('id', teacherId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
