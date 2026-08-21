import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/firebase/notification_storage.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';

class NotificationsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<NotificationModel>>> getNotifications(
    String userId,
  ) async {
    final List<NotificationModel> combined = [];
    final Set<String> seenIds = {};
    final Set<String> seenContent = {};

    // 1. Fetch remote notifications from Supabase
    try {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      for (final e in data) {
        final model = NotificationModel.fromJson(e);
        if (seenIds.add(model.id)) {
          seenContent.add('${model.title}_${model.body}');
          combined.add(model);
        }
      }
    } catch (_) {}

    // 2. Fetch locally stored Firebase push notifications
    try {
      final local = await NotificationStorage.getLocalNotifications(userId);
      for (final model in local) {
        final contentKey = '${model.title}_${model.body}';
        if (seenIds.add(model.id) && !seenContent.contains(contentKey)) {
          seenContent.add(contentKey);
          combined.add(model);
        }
      }
    } catch (_) {}

    // 3. Sort by creation date descending
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 4. Update the reactive unread badge count
    NotificationStorage.updateUnreadCountFromList(combined);

    return ApiResult.success(combined);
  }

  Future<ApiResult<void>> markAsRead(String notificationId) async {
    await NotificationStorage.markAsRead(notificationId);
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (_) {}
    return const ApiResult.success(null);
  }

  Future<ApiResult<void>> markAllAsRead(String userId) async {
    await NotificationStorage.markAllAsRead();
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
    } catch (_) {}
    return const ApiResult.success(null);
  }
}

