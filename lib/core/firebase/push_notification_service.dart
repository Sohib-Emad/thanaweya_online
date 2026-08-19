import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'token_manager.dart';
import 'notification_handler.dart';

/// Required entry point for FCM messages received while the app is in the
/// background or terminated. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[Push] background message: ${message.notification?.title} '
    '(${message.messageId})',
  );
}

/// Centralises Firebase Cloud Messaging and local notification handling.
///
/// Responsibilities:
///   * Requests permission (iOS / Android 13+)
///   * Registers / refreshes the FCM token in Supabase
///   * Shows a local notification while the app is in the foreground
///   * Navigates to the notifications screen when a notification is tapped
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

    await NotificationHandler.initLocalNotifications(
      _localNotifications,
      onNotificationTap: _navigateToNotifications,
    );

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[Push] permission status: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage
        .listen((m) => NotificationHandler.showLocalNotification(_localNotifications, m));

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((_) => _navigateToNotifications());

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _navigateToNotifications());
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

  void _navigateToNotifications() {
    NotificationHandler.navigateToNotifications(navigatorKey);
  }
}
