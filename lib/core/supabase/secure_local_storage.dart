import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists the Supabase auth session (access + refresh tokens) in
/// [FlutterSecureStorage] (Keychain/Keystore) and keeps a lightweight
/// login-status flag in [SharedPreferences] for fast startup checks.
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({
    String? persistSessionKey,
    FlutterSecureStorage? secureStorage,
  })  : _persistSessionKey = persistSessionKey ?? kSessionKey,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Key used to persist the session in secure storage.
  static const String kSessionKey = 'sb-auth-token';

  /// Key used to store the lightweight login-status flag.
  static const String kLoggedInKey = 'is_logged_in';

  final String _persistSessionKey;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return await _secureStorage.containsKey(key: _persistSessionKey);
  }

  @override
  Future<String?> accessToken() async {
    return await _secureStorage.read(key: _persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await _secureStorage.delete(key: _persistSessionKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLoggedInKey, false);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _secureStorage.write(
      key: _persistSessionKey,
      value: persistSessionString,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLoggedInKey, true);
  }

  /// Quick startup check of the stored login-status flag.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kLoggedInKey) ?? false;
  }

  /// Reads the raw persisted session from secure storage.
  static Future<String?> readSession() async {
    return const FlutterSecureStorage().read(key: kSessionKey);
  }
}
