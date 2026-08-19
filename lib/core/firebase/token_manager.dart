import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages FCM device token persistence in the Supabase `device_tokens` table.
class TokenManager {
  TokenManager._();

  /// Last known signed-in user ID, kept so tokens can be removed on sign-out
  /// when `auth.currentUser` is already null.
  static String? currentUserId;

  /// Saves (upserts) the FCM token for the given or current user.
  static Future<void> saveToken(String? token, {String? userId}) async {
    if (token == null || token.isEmpty) return;

    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    final uid = userId ?? session?.user.id ?? client.auth.currentUser?.id;

    if (uid == null || uid.isEmpty) return;

    final platform =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

    try {
      await client.from('device_tokens').upsert(
        {
          'user_id': uid,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'token',
      );
      debugPrint('[Push] token registered ($platform)');
    } catch (_) {}
  }

  /// Removes every registered token for the given user.
  static Future<void> deleteTokensFor(String userId) async {
    try {
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('user_id', userId);
      debugPrint('[Push] tokens removed for $userId');
    } catch (e) {
      debugPrint('[Push] failed to remove tokens: $e');
    }
  }

  /// Removes tokens for the current or last-known user.
  static Future<void> removeTokens() async {
    final userId =
        currentUserId ?? Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await deleteTokensFor(userId);
  }
}
