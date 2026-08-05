import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';

class NotificationsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<NotificationModel>>> getNotifications(
    String userId,
  ) async {
    try {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      return ApiResult.success(
        data.map((e) => NotificationModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
