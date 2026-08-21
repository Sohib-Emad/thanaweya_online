import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';

class AdminPushTokensRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches all registered device tokens with their associated user & teacher details.
  Future<ApiResult<List<Map<String, dynamic>>>> getAllDeviceTokens() async {
    try {
      final data = await _client
          .from('device_tokens')
          .select('id, user_id, token, platform, created_at, updated_at')
          .order('updated_at', ascending: false);

      final tokenList = List<Map<String, dynamic>>.from(data);
      if (tokenList.isEmpty) return const ApiResult.success([]);

      final userIds = tokenList
          .map((t) => t['user_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      // Look up user details
      final usersMap = await StudentUserLookup().forIds(userIds);

      // Check teachers table to identify all teachers reliably
      final teachersMap = <String, Map<String, dynamic>>{};
      try {
        final teachersData = await _client
            .from('teachers')
            .select('id, stage, approval_status, subjects(name_ar)')
            .inFilter('id', userIds);
        for (final t in teachersData) {
          final tid = t['id'] as String? ?? '';
          if (tid.isNotEmpty) {
            teachersMap[tid] = Map<String, dynamic>.from(t);
          }
        }
      } catch (_) {}

      final enriched = <Map<String, dynamic>>[];
      for (final t in tokenList) {
        final uid = t['user_id'] as String? ?? '';
        final user = usersMap[uid] ?? <String, dynamic>{};
        final teacherInfo = teachersMap[uid];

        final isTeacher = teacherInfo != null ||
            (user['role'] as String?)?.toLowerCase() == 'teacher';

        final subjectName = (teacherInfo?['subjects']
                as Map<String, dynamic>?)?['name_ar'] as String? ??
            '';

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

  /// Sends in-app and push notification to target audience.
  /// [targetType] can be: 'all', 'students', 'teachers', or 'specific'.
  Future<ApiResult<int>> sendNotification({
    required String title,
    required String body,
    required String targetType, // 'all', 'students', 'teachers', 'specific'
    String? specificUserId,
    String category = 'admin_broadcast',
  }) async {
    try {
      List<String> targetUserIds = [];

      if (targetType == 'specific' && specificUserId != null) {
        targetUserIds = [specificUserId];
      } else if (targetType == 'students') {
        final students = await _client.from('students').select('id');
        targetUserIds = (students as List)
            .map((s) => s['id'] as String?)
            .whereType<String>()
            .toList();
      } else if (targetType == 'teachers') {
        final teachers = await _client.from('teachers').select('id');
        targetUserIds = (teachers as List)
            .map((t) => t['id'] as String?)
            .whereType<String>()
            .toList();
      } else {
        // All users from users table
        final users = await _client.from('users').select('id');
        targetUserIds = (users as List)
            .map((u) => u['id'] as String?)
            .whereType<String>()
            .toList();
      }

      if (targetUserIds.isEmpty) {
        return const ApiResult.success(0);
      }

      // Batch insert into notifications table in chunks of 100
      final now = DateTime.now().toUtc().toIso8601String();
      const chunkSize = 100;
      int insertedCount = 0;

      for (var i = 0; i < targetUserIds.length; i += chunkSize) {
        final end = (i + chunkSize < targetUserIds.length)
            ? i + chunkSize
            : targetUserIds.length;
        final chunk = targetUserIds.sublist(i, end);

        final rows = chunk.map((uid) => {
          'user_id': uid,
          'title': title,
          'body': body,
          'category': category,
          'is_read': false,
          'created_at': now,
        }).toList();

        await _client.from('notifications').insert(rows);
        insertedCount += chunk.length;
      }

      return ApiResult.success(insertedCount);
    } catch (e) {
      debugPrint('[AdminPushTokensRepo] sendNotification error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes a device token.
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
