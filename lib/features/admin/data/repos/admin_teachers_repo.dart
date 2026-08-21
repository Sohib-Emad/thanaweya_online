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
            users!inner(id, full_name, email, phone),
            subjects(id, name_ar)
          ''').eq('approval_status', 'pending').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // Fallback query if requires_renewal column is being added
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
            users!inner(id, full_name, email, phone),
            subjects(id, name_ar)
          ''').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // Fallback query if requires_renewal column is being added
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
