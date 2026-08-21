import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';

/// Local persistent storage for all received Firebase push notifications and unread badge count.
class NotificationStorage {
  NotificationStorage._();

  static const String _storageKey = 'cached_fcm_notifications_v1';
  static const String _unreadCountKey = 'cached_fcm_unread_count_v1';

  /// Reactive notifier for the unread notifications count across the entire app.
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Initializes the storage and refreshes the unread count.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getLocalNotifications(null);
      final unread = notifications.where((n) => !n.isRead).length;
      unreadCountNotifier.value = unread;
      await prefs.setInt(_unreadCountKey, unread);
    } catch (_) {}
  }

  /// Cleans trailing/leading punctuation from URLs.
  static String cleanUrl(String raw) {
    var url = raw.trim();
    while (url.isNotEmpty &&
        (url.endsWith('.') ||
            url.endsWith(',') ||
            url.endsWith('،') ||
            url.endsWith(';') ||
            url.endsWith('؛') ||
            url.endsWith(')') ||
            url.endsWith(']') ||
            url.endsWith('}') ||
            url.endsWith('"') ||
            url.endsWith("'") ||
            url.endsWith('>'))) {
      url = url.substring(0, url.length - 1);
    }
    while (url.isNotEmpty &&
        (url.startsWith('(') ||
            url.startsWith('[') ||
            url.startsWith('{') ||
            url.startsWith('"') ||
            url.startsWith("'") ||
            url.startsWith('<'))) {
      url = url.substring(1);
    }
    return url.trim();
  }

  /// Extracts the URL/link if present in data payload or notification body text.
  static String? extractLink(RemoteMessage message) {
    // 1. Data payload fields
    final data = message.data;
    if (data.isNotEmpty) {
      for (final key in ['link', 'url', 'click_action', 'uri', 'target_url', 'action_url']) {
        final val = data[key]?.toString().trim();
        if (val != null && val.isNotEmpty) {
          if (val.startsWith('http://') || val.startsWith('https://') || val.startsWith('www.')) {
            return cleanUrl(val);
          }
        }
      }
    }

    // 2. Notification body & title text regex search
    final body = message.notification?.body ?? message.data['body']?.toString() ?? '';
    final title = message.notification?.title ?? message.data['title']?.toString() ?? '';
    final textToSearch = '$body $title';
    final urlRegex = RegExp(r'(https?://[^\s]+|www\.[^\s]+)');
    final match = urlRegex.firstMatch(textToSearch);
    if (match != null) {
      return cleanUrl(match.group(0)!);
    }

    return null;
  }

  /// Saves an incoming [RemoteMessage] to local persistent storage.
  static Future<void> saveRemoteMessage(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final title = message.notification?.title ?? message.data['title']?.toString() ?? '';
      final body = message.notification?.body ?? message.data['body']?.toString() ?? '';

      if (title.isEmpty && body.isEmpty) return;

      final messageId = message.messageId ??
          'fcm_${DateTime.now().millisecondsSinceEpoch}_${title.hashCode}';
      final category = message.data['category']?.toString() ?? 'system';
      final link = extractLink(message);
      final now = DateTime.now();

      final existingJsonList = prefs.getStringList(_storageKey) ?? [];
      final List<Map<String, dynamic>> items = [];

      for (final str in existingJsonList) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          // Avoid duplicates by message id or matching title+body within 1 minute
          if (map['id'] == messageId) return;
          items.add(map);
        } catch (_) {}
      }

      final newMap = {
        'id': messageId,
        'user_id': message.data['user_id']?.toString() ?? '',
        'title': title,
        'body': body,
        'category': category,
        'link': link,
        'is_read': false,
        'created_at': now.toIso8601String(),
      };

      // Add as the newest notification
      items.insert(0, newMap);

      // Keep up to 200 notifications
      final trimmed = items.take(200).map((m) => jsonEncode(m)).toList();
      await prefs.setStringList(_storageKey, trimmed);

      // Update unread count
      final unread = items.where((m) => m['is_read'] != true).length;
      unreadCountNotifier.value = unread;
      await prefs.setInt(_unreadCountKey, unread);
    } catch (_) {}
  }

  /// Retrieves all cached local notifications.
  static Future<List<NotificationModel>> getLocalNotifications(String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      final List<NotificationModel> result = [];

      for (final str in list) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          final itemUserId = map['user_id']?.toString();
          // Include if userId matches or if notification is global/broadcast (empty user_id)
          if (userId == null || itemUserId == null || itemUserId.isEmpty || itemUserId == userId) {
            result.add(
              NotificationModel(
                id: map['id']?.toString() ?? '',
                userId: itemUserId ?? '',
                title: map['title']?.toString() ?? '',
                body: map['body']?.toString() ?? '',
                category: map['category']?.toString() ?? 'system',
                link: map['link']?.toString(),
                isRead: map['is_read'] == true,
                createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
              ),
            );
          }
        } catch (_) {}
      }

      return result;
    } catch (_) {
      return [];
    }
  }

  /// Marks a specific notification as read in local storage.
  static Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      final List<String> updated = [];
      int unread = 0;

      for (final str in list) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          if (map['id'] == id) {
            map['is_read'] = true;
          }
          if (map['is_read'] != true) {
            unread++;
          }
          updated.add(jsonEncode(map));
        } catch (_) {
          updated.add(str);
        }
      }

      await prefs.setStringList(_storageKey, updated);
      unreadCountNotifier.value = unread;
      await prefs.setInt(_unreadCountKey, unread);
    } catch (_) {}
  }

  /// Marks all notifications as read in local storage.
  static Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      final List<String> updated = [];

      for (final str in list) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          map['is_read'] = true;
          updated.add(jsonEncode(map));
        } catch (_) {
          updated.add(str);
        }
      }

      await prefs.setStringList(_storageKey, updated);
      unreadCountNotifier.value = 0;
      await prefs.setInt(_unreadCountKey, 0);
    } catch (_) {}
  }

  /// Updates the unread count directly from loaded notifications list.
  static void updateUnreadCountFromList(List<NotificationModel> list) {
    final unread = list.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
  }
}
