import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';

extension AdminTeachersRepoPassword on AdminTeachersRepo {
  /// Sets or updates a teacher's password directly from the Admin panel.
  Future<ApiResult<void>> updateUserPassword(
    String userId,
    String newPassword, {
    String? email,
  }) async {
    try {
      debugPrint('[AdminTeachersRepo] updateUserPassword: userId=$userId, email=$email');
      String? targetEmail = email;
      if (targetEmail == null || targetEmail.isEmpty) {
        try {
          final userRow = await client.from('users').select('email').eq('id', userId).maybeSingle();
          targetEmail = userRow?['email'] as String?;
        } catch (_) {}
      }

      final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';

      if (serviceRoleKey.isNotEmpty) {
        String authUserId = userId;
        if (targetEmail != null) {
          try {
            final res = await client.rpc('find_auth_user_id', params: {'p_email': targetEmail});
            if (res != null && res.toString().isNotEmpty) authUserId = res.toString();
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
            await client.from('users').update({'plain_password': newPassword}).eq('id', userId);
            await client.from('teachers').update({'plain_password': newPassword}).eq('id', userId);
          } catch (_) {}
          return const ApiResult.success(null);
        }
      }

      final res = await client.rpc('admin_set_user_password', params: {
        'p_user_id': userId,
        'p_new_password': newPassword,
        if (targetEmail != null && targetEmail.isNotEmpty) 'p_email': targetEmail,
      });
      final map = res as Map<String, dynamic>?;
      if (map?['ok'] == true) return const ApiResult.success(null);
      return ApiResult.failure(map?['error']?.toString() ?? 'تعذر تغيير كلمة المرور');
    } catch (e) {
      try {
        await client.from('users').update({'plain_password': newPassword}).eq('id', userId);
        await client.from('teachers').update({'plain_password': newPassword}).eq('id', userId);
        return const ApiResult.success(null);
      } catch (e2) {
        return ApiErrorHandler.handleException(e2);
      }
    }
  }
}
