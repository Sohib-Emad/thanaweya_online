import 'package:flutter/foundation.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_push_tokens_repo.dart';

extension AdminPushTokensRepoSender on AdminPushTokensRepo {
  /// Sends in-app and push notification to target audience.
  Future<ApiResult<int>> sendNotification({
    required String title,
    required String body,
    required String targetType,
    String? specificUserId,
    String category = 'admin_broadcast',
  }) async {
    try {
      List<String> targetUserIds = [];

      if (targetType == 'specific' && specificUserId != null) {
        targetUserIds = [specificUserId];
      } else if (targetType == 'students') {
        final students = await client.from('students').select('id');
        targetUserIds = (students as List).map((s) => s['id'] as String?).whereType<String>().toList();
      } else if (targetType == 'teachers') {
        final teachers = await client.from('teachers').select('id');
        targetUserIds = (teachers as List).map((t) => t['id'] as String?).whereType<String>().toList();
      } else {
        final users = await client.from('users').select('id');
        targetUserIds = (users as List).map((u) => u['id'] as String?).whereType<String>().toList();
      }

      if (targetUserIds.isEmpty) return const ApiResult.success(0);

      final now = DateTime.now().toUtc().toIso8601String();
      const chunkSize = 100;
      int insertedCount = 0;

      for (var i = 0; i < targetUserIds.length; i += chunkSize) {
        final end = (i + chunkSize < targetUserIds.length) ? i + chunkSize : targetUserIds.length;
        final chunk = targetUserIds.sublist(i, end);
        final rows = chunk.map((uid) => {
          'user_id': uid,
          'title': title,
          'body': body,
          'category': category,
          'is_read': false,
          'created_at': now,
        }).toList();

        await client.from('notifications').insert(rows);
        insertedCount += chunk.length;
      }
      return ApiResult.success(insertedCount);
    } catch (e) {
      debugPrint('[AdminPushTokensRepo] sendNotification error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
