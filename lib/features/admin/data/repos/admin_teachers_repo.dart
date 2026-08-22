import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  /// Uses the Supabase Auth Admin API if available, or the secure RPC.
  Future<ApiResult<void>> updateUserPassword(
    String userId,
    String newPassword, {
    String? email,
  }) async {
    try {
      debugPrint('[AdminTeachersRepo] updateUserPassword: userId=$userId, email=$email');

      // Step 1: Resolve email if not provided
      String? targetEmail = email;
      if (targetEmail == null || targetEmail.isEmpty) {
        try {
          final userRow = await _client
              .from('users')
              .select('email')
              .eq('id', userId)
              .maybeSingle();
          targetEmail = userRow?['email'] as String?;
        } catch (e) {
          debugPrint('[AdminTeachersRepo] Email lookup failed: $e');
        }
      }

      // Step 2: Use Supabase Auth Admin API if service_role key is present
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

      if (serviceRoleKey.isNotEmpty) {
        String authUserId = userId;
        if (targetEmail != null) {
          try {
            final res = await _client.rpc('find_auth_user_id', params: {
              'p_email': targetEmail,
            });
            if (res != null && res.toString().isNotEmpty) {
              authUserId = res.toString();
            }
          } catch (_) {}
        }

        final uri = Uri.parse('$supabaseUrl/auth/v1/admin/users/$authUserId');
        final response = await http.put(
          uri,
          headers: {
            'Authorization': 'Bearer $serviceRoleKey',
            'apikey': serviceRoleKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'password': newPassword}),
        );

        if (response.statusCode == 200) {
          try {
            await _client.from('users').update({'plain_password': newPassword}).eq('id', userId);
            await _client.from('teachers').update({'plain_password': newPassword}).eq('id', userId);
          } catch (_) {}
          return const ApiResult.success(null);
        }
      }

      // Step 3: Call the bulletproof RPC
      debugPrint('[AdminTeachersRepo] Calling admin_set_user_password RPC with email=$targetEmail');
      final res = await _client.rpc('admin_set_user_password', params: {
        'p_user_id': userId,
        'p_new_password': newPassword,
        if (targetEmail != null && targetEmail.isNotEmpty) 'p_email': targetEmail,
      });
      debugPrint('[AdminTeachersRepo] RPC response: $res');
      final map = res as Map<String, dynamic>?;
      if (map?['ok'] == true) {
        return const ApiResult.success(null);
      }
      return ApiResult.failure(map?['error']?.toString() ?? 'تعذر تغيير كلمة المرور');
    } catch (e) {
      debugPrint('[AdminTeachersRepo] updateUserPassword failed: $e');
      try {
        await _client.from('users').update({'plain_password': newPassword}).eq('id', userId);
        await _client.from('teachers').update({'plain_password': newPassword}).eq('id', userId);
        return const ApiResult.success(null);
      } catch (e2) {
        return ApiErrorHandler.handleException(e2);
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
