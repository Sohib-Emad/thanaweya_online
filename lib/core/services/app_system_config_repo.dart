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

  const AppSystemConfig({
    this.isMaintenanceMode = false,
    this.maintenanceMessage = 'التطبيق قيد أعمال الصيانة والتطوير حالياً، سنعود قريباً بإذن الله.',
    this.isUpdateRequired = false,
    this.updateMessage = 'يتوفر إصدار جديد وأكثر استقراراً من التطبيق، يرجى التحديث للمتابعة.',
    this.updateUrl = 'https://play.google.com',
    this.supportPhone = '201096462825',
  });

  AppSystemConfig copyWith({
    bool? isMaintenanceMode,
    String? maintenanceMessage,
    bool? isUpdateRequired,
    String? updateMessage,
    String? updateUrl,
    String? supportPhone,
  }) {
    return AppSystemConfig(
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      updateMessage: updateMessage ?? this.updateMessage,
      updateUrl: updateUrl ?? this.updateUrl,
      supportPhone: supportPhone ?? this.supportPhone,
    );
  }
}

/// Repository for reading and updating global app maintenance and update modes.
class AppSystemConfigRepo {
  static final AppSystemConfigRepo _instance = AppSystemConfigRepo._internal();
  factory AppSystemConfigRepo() => _instance;
  AppSystemConfigRepo._internal();

  AppSystemConfig _cachedConfig = const AppSystemConfig();
  AppSystemConfig get cachedConfig => _cachedConfig;

  SupabaseClient get _client => Supabase.instance.client;

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

  /// Updates force update mode state.
  Future<bool> setUpdateMode({
    required bool enabled,
    String? message,
    String? updateUrl,
    String? supportPhone,
  }) async {
    _cachedConfig = _cachedConfig.copyWith(
      isUpdateRequired: enabled,
      updateMessage: message,
      updateUrl: updateUrl,
      supportPhone: supportPhone,
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
