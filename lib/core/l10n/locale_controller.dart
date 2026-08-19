import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app language and persists the user's choice.
///
/// Arabic is the default locale; switching to English is supported by the
/// [AppLocalizations] delegate. The whole app rebuilds when the locale
/// changes via [ListenableBuilder] in `main.dart`.
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const String _prefsKey = 'app_locale';
  static const Locale defaultLocale = Locale('ar');
  static const List<String> supportedCodes = ['ar', 'en'];

  Locale _locale = defaultLocale;
  bool _loaded = false;

  Locale get locale => _locale;

  /// Arabic label shown in the profile's language row.
  String get label => _locale.languageCode == 'en' ? 'English' : 'العربية';

  bool get isLoaded => _loaded;

  /// Restores the saved locale (called once before `runApp`).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && supportedCodes.contains(code)) {
        _locale = Locale(code);
      }
    } catch (_) {
      // Keep the default on any storage error.
    }
    _loaded = true;
    notifyListeners();
  }

  /// Applies a new language and persists it.
  Future<void> setLocale(String languageCode) async {
    if (!supportedCodes.contains(languageCode)) return;
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, languageCode);
    } catch (_) {
      // Non-fatal — the change still applies for this session.
    }
  }
}
