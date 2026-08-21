import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router/app_router.dart';
import 'notification_storage.dart';

/// Handles foreground notification display, badge counts, and tap-based navigation/link opening.
class NotificationHandler {
  NotificationHandler._();

  static const String _channelId = 'thanaweya_notifications';
  static const String _channelName = 'إشعارات ثانوية أونلاين';

  /// Initializes the local notifications plugin with platform settings.
  static Future<void> initLocalNotifications(
    FlutterLocalNotificationsPlugin plugin, {
    required void Function(String? payload) onNotificationTap,
  }) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap(response.payload);
      },
    );
  }

  /// Displays a local notification from an incoming FCM foreground message with badge counter.
  static void showLocalNotification(
    FlutterLocalNotificationsPlugin plugin,
    RemoteMessage message,
  ) {
    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title == null || title.isEmpty) return;

    final unreadCount = NotificationStorage.unreadCountNotifier.value;
    final link = NotificationStorage.extractLink(message);

    plugin.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelName,
          importance: Importance.high,
          priority: Priority.high,
          channelShowBadge: true,
          number: unreadCount,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: unreadCount,
        ),
      ),
      payload: link ?? message.data['notificationId']?.toString(),
    );
  }

  /// Navigates to the notifications screen or opens a link if present.
  static Future<void> handleNotificationAction(
    GlobalKey<NavigatorState> navigatorKey,
    String? payload,
  ) async {
    if (payload != null &&
        (payload.startsWith('http://') || payload.startsWith('https://'))) {
      try {
        final uri = Uri.parse(payload);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(AppRouter.notifications);
  }
}
