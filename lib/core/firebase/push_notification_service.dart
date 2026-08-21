import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'token_manager.dart';
import 'notification_handler.dart';
import 'notification_storage.dart';

/// Required entry point for FCM messages received while the app is in the
/// background or terminated. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[Push] background message: ${message.notification?.title} '
    '(${message.messageId})',
  );
  await NotificationStorage.saveRemoteMessage(message);
}

/// Centralises Firebase Cloud Messaging and local notification handling.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _initialized = false;

  /// Call once after `Firebase.initializeApp` and `Supabase.initialize`.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await NotificationStorage.init();

    await NotificationHandler.initLocalNotifications(
      _localNotifications,
      onNotificationTap: (payload) => _handleNotificationTap(payload),
    );

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[Push] permission status: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((m) async {
      await NotificationStorage.saveRemoteMessage(m);
      NotificationHandler.showLocalNotification(_localNotifications, m);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final link = NotificationStorage.extractLink(m);
      _handleNotificationTap(link);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final link = NotificationStorage.extractLink(initialMessage);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handleNotificationTap(link));
    }

    _messaging.onTokenRefresh.listen((token) => TokenManager.saveToken(token));
    await _registerCurrentUser();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          final uid = data.session?.user.id;
          if (uid != null) {
            TokenManager.currentUserId = uid;
            _messaging
                .getToken()
                .then((token) => TokenManager.saveToken(token, userId: uid));
          }
        case AuthChangeEvent.signedOut:
          if (TokenManager.currentUserId != null) {
            TokenManager.deleteTokensFor(TokenManager.currentUserId!);
            TokenManager.currentUserId = null;
          }
        default:
          break;
      }
    });
  }

  Future<void> _registerCurrentUser() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      TokenManager.currentUserId = userId;
      final token = await _messaging.getToken();
      await TokenManager.saveToken(token, userId: userId);
    }
  }

  void _handleNotificationTap(String? payload) {
    NotificationHandler.handleNotificationAction(navigatorKey, payload);
  }
}
