import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminTeachersRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getPendingTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, stage, bio, approval_status, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url,
            payment_receipt_url, selected_plan, payment_method, subscription_amount, created_at,
            users!inner(id, full_name, email, phone),
            subjects(id, name_ar)
          ''').eq('approval_status', 'pending').order('created_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getAllTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, stage, bio, approval_status, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url,
            payment_receipt_url, selected_plan, payment_method, subscription_amount, rejection_reason, created_at,
            users!inner(id, full_name, email, phone),
            subjects(id, name_ar)
          ''').order('created_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
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
}
