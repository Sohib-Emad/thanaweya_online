import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';
export 'admin_push_tokens_sender_ext.dart';

class AdminPushTokensRepo {
  final SupabaseClient _client;

  AdminPushTokensRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  Future<ApiResult<List<Map<String, dynamic>>>> getAllDeviceTokens() async {
    try {
      final data = await _client
          .from('device_tokens')
          .select('id, user_id, token, platform, created_at, updated_at')
          .order('updated_at', ascending: false);

      final tokenList = List<Map<String, dynamic>>.from(data);
      if (tokenList.isEmpty) return const ApiResult.success([]);

      final userIds = tokenList.map((t) => t['user_id'] as String?).whereType<String>().toSet().toList();
      final usersMap = await StudentUserLookup().forIds(userIds);

      final teachersMap = <String, Map<String, dynamic>>{};
      try {
        final teachersData = await _client
            .from('teachers')
            .select('id, stage, approval_status, subjects(name_ar)')
            .inFilter('id', userIds);
        for (final t in teachersData) {
          final tid = t['id'] as String? ?? '';
          if (tid.isNotEmpty) teachersMap[tid] = Map<String, dynamic>.from(t);
        }
      } catch (_) {}

      final enriched = <Map<String, dynamic>>[];
      for (final t in tokenList) {
        final uid = t['user_id'] as String? ?? '';
        final user = usersMap[uid] ?? <String, dynamic>{};
        final teacherInfo = teachersMap[uid];
        final isTeacher = teacherInfo != null || (user['role'] as String?)?.toLowerCase() == 'teacher';
        final subjectName = (teacherInfo?['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '';

        enriched.add({
          ...t,
          'user': user,
          'full_name': user['full_name'] ?? (isTeacher ? 'معلم' : 'طالب'),
          'email': user['email'] ?? '',
          'role': isTeacher ? 'teacher' : (user['role'] ?? 'student'),
          'phone': user['phone'] ?? '',
          'avatar_url': user['avatar_url'],
          'subject_name': subjectName,
          'stage': teacherInfo?['stage'] ?? '',
        });
      }
      return ApiResult.success(enriched);
    } catch (e) {
      debugPrint('[AdminPushTokensRepo] getAllDeviceTokens error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteDeviceToken(String tokenId) async {
    try {
      await _client.from('device_tokens').delete().eq('id', tokenId);
      return const ApiResult.success(null);
    } catch (e) {
      debugPrint('[AdminPushTokensRepo] deleteDeviceToken error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
