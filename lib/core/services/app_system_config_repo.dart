import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model representing the global application status.
class AppSystemConfig {
  final bool isMaintenanceMode;
  final String maintenanceMessage;
  final bool isUpdateRequired;
  final String updateMessage;
  final String updateUrl;
  final String supportPhone;
  final String minVersion;
  final String latestVersion;

  const AppSystemConfig({
    this.isMaintenanceMode = false,
    this.maintenanceMessage = 'التطبيق قيد أعمال الصيانة والتطوير حالياً، سنعود قريباً بإذن الله.',
    this.isUpdateRequired = false,
    this.updateMessage = 'هذه النسخة ليست متاحة الآن، يرجى التحديث إلى أحدث إصدار للمتابعة.',
    this.updateUrl = 'https://play.google.com',
    this.supportPhone = '201096462825',
    this.minVersion = '1.0.0',
    this.latestVersion = '1.0.0',
  });

  /// Checks whether update is enforced either via global switch or version comparison.
  bool isUpdateEnforced(String clientVersion) {
    final cleanClient = clientVersion.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final cleanMin = minVersion.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final cleanLatest = latestVersion.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '').trim();

    // 1. If the client version is equal to or newer than latestVersion, NEVER block!
    if (cleanLatest.isNotEmpty && !AppSystemConfigRepo.isVersionOlder(cleanClient, cleanLatest)) {
      return false;
    }

    // 2. If update_mode (قفل النسخ القديمة إجبارياً) is active:
    // Enforce update for anyone older than latestVersion (or minVersion if higher)
    if (isUpdateRequired) {
      final threshold = AppSystemConfigRepo.isVersionOlder(cleanLatest, cleanMin) ? cleanMin : cleanLatest;
      if (threshold.isNotEmpty) {
        return AppSystemConfigRepo.isVersionOlder(cleanClient, threshold);
      }
    }

    // 3. If update_mode toggle is OFF, only enforce if strictly below minVersion
    if (cleanMin.isNotEmpty && cleanMin != '0.0.0') {
      return AppSystemConfigRepo.isVersionOlder(cleanClient, cleanMin);
    }

    return false;
  }

  AppSystemConfig copyWith({
    bool? isMaintenanceMode,
    String? maintenanceMessage,
    bool? isUpdateRequired,
    String? updateMessage,
    String? updateUrl,
    String? supportPhone,
    String? minVersion,
    String? latestVersion,
  }) {
    return AppSystemConfig(
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      updateMessage: updateMessage ?? this.updateMessage,
      updateUrl: updateUrl ?? this.updateUrl,
      supportPhone: supportPhone ?? this.supportPhone,
      minVersion: minVersion ?? this.minVersion,
      latestVersion: latestVersion ?? this.latestVersion,
    );
  }
}

/// Repository for reading and updating global app maintenance and update modes.
class AppSystemConfigRepo {
  static const String currentAppVersion = '1.0.1';

  static final AppSystemConfigRepo _instance = AppSystemConfigRepo._internal();
  factory AppSystemConfigRepo() => _instance;
  AppSystemConfigRepo._internal();

  AppSystemConfig _cachedConfig = const AppSystemConfig();
  AppSystemConfig get cachedConfig => _cachedConfig;

  SupabaseClient get _client => Supabase.instance.client;

  /// Helper to check if [clientVer] is strictly older than [requiredVer] (semver-like).
  static bool isVersionOlder(String clientVer, String requiredVer) {
    try {
      String sanitize(String v) => v.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      final cClean = sanitize(clientVer);
      final rClean = sanitize(requiredVer);
      if (cClean.isEmpty || rClean.isEmpty) return false;

      final cParts = cClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final rParts = rClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (cParts.length < 3) {
        cParts.add(0);
      }
      while (rParts.length < 3) {
        rParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (cParts[i] < rParts[i]) return true;
        if (cParts[i] > rParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetches latest system config from Supabase or returns cached fallback.
  Future<AppSystemConfig> fetchConfig() async {
    try {
      final data = await _client
          .from('system_settings')
          .select()
          .eq('key', 'app_modes')
          .maybeSingle();

      if (data != null && data['value'] is Map) {
        final val = Map<String, dynamic>.from(data['value'] as Map);
        _cachedConfig = AppSystemConfig(
          isMaintenanceMode: val['maintenance_mode'] == true,
          maintenanceMessage: (val['maintenance_message'] as String?) ??
              _cachedConfig.maintenanceMessage,
          isUpdateRequired: val['update_mode'] == true,
          updateMessage: (val['update_message'] as String?) ??
              _cachedConfig.updateMessage,
          updateUrl: (val['update_url'] as String?) ??
              _cachedConfig.updateUrl,
          supportPhone: (val['support_phone'] as String?) ??
              _cachedConfig.supportPhone,
          minVersion: (val['min_version'] as String?) ??
              _cachedConfig.minVersion,
          latestVersion: (val['latest_version'] as String?) ??
              _cachedConfig.latestVersion,
        );
      }
    } catch (e) {
      debugPrint('[AppSystemConfigRepo] fetch error (using fallback): $e');
    }
    return _cachedConfig;
  }

  /// Updates maintenance mode state.
  Future<bool> setMaintenanceMode({
    required bool enabled,
    String? message,
  }) async {
    _cachedConfig = _cachedConfig.copyWith(
      isMaintenanceMode: enabled,
      maintenanceMessage: message,
    );
    return _saveToRemote();
  }

  /// Updates force update mode and version requirements.
  Future<bool> setUpdateMode({
    required bool enabled,
    String? message,
    String? updateUrl,
    String? supportPhone,
    String? minVersion,
    String? latestVersion,
  }) async {
    _cachedConfig = _cachedConfig.copyWith(
      isUpdateRequired: enabled,
      updateMessage: message,
      updateUrl: updateUrl,
      supportPhone: supportPhone,
      minVersion: minVersion,
      latestVersion: latestVersion,
    );
    return _saveToRemote();
  }

  Future<bool> _saveToRemote() async {
    try {
      final payload = {
        'key': 'app_modes',
        'value': {
          'maintenance_mode': _cachedConfig.isMaintenanceMode,
          'maintenance_message': _cachedConfig.maintenanceMessage,
          'update_mode': _cachedConfig.isUpdateRequired,
          'update_message': _cachedConfig.updateMessage,
          'update_url': _cachedConfig.updateUrl,
          'support_phone': _cachedConfig.supportPhone,
          'min_version': _cachedConfig.minVersion,
          'latest_version': _cachedConfig.latestVersion,
        },
      };
      await _client.from('system_settings').upsert(payload);
      return true;
    } catch (e) {
      debugPrint('[AppSystemConfigRepo] save remote error: $e');
      return true; // Still true locally for session
    }
  }
}
