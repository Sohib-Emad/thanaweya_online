import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../router/app_router.dart';

/// Handles foreground notification display and tap-based navigation.
class NotificationHandler {
  NotificationHandler._();

  static const String _channelId = 'thanaweya_notifications';
  static const String _channelName = 'إشعارات ثانوية أونلاين';

  /// Initializes the local notifications plugin with platform settings.
  static Future<void> initLocalNotifications(
    FlutterLocalNotificationsPlugin plugin, {
    required void Function() onNotificationTap,
  }) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (_) => onNotificationTap(),
    );
  }

  /// Displays a local notification from an incoming FCM foreground message.
  static void showLocalNotification(
    FlutterLocalNotificationsPlugin plugin,
    RemoteMessage message,
  ) {
    final title = message.notification?.title;
    final body = message.notification?.body;
    if (title == null) return;

    plugin.show(
      id: message.messageId?.hashCode ?? 0,
      title: title,
      body: body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['notificationId'],
    );
  }

  /// Navigates to the notifications screen using the provided navigator key.
  static void navigateToNotifications(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(AppRouter.notifications);
  }
}
