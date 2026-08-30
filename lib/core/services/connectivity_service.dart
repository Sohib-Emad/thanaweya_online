import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Global service monitoring network connectivity status across the entire application.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  static ConnectivityService get instance => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _offlineDebounceTimer;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);
  bool get isConnected => isConnectedNotifier.value;

  bool _isChecking = false;

  /// Initializes the connectivity listener.
  void initialize() {
    _subscription?.cancel();

    // Check initial state gracefully
    checkConnectivity();

    // Listen for future changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityResults(results);
    });
  }

  void _handleConnectivityResults(List<ConnectivityResult> results) {
    final hasHardwareConnection = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );

    if (!hasHardwareConnection) {
      _setConnected(false);
      return;
    }

    // Hardware reports connected, verify actual reachability
    _verifyActualInternet();
  }

  Future<void> _verifyActualInternet() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty) {
        _setConnected(true);
      } else {
        _setConnected(false);
      }
    } catch (_) {
      _setConnected(false);
    } finally {
      _isChecking = false;
    }
  }

  void _setConnected(bool connected) {
    if (connected) {
      _offlineDebounceTimer?.cancel();
      _offlineDebounceTimer = null;
      if (!isConnectedNotifier.value) {
        isConnectedNotifier.value = true;
        debugPrint('[ConnectivityService] Connection status restored -> isConnected: true');
      }
    } else {
      if (isConnectedNotifier.value && _offlineDebounceTimer == null) {
        // Debounce offline event by 1500ms to prevent startup blips or network handover flickers
        _offlineDebounceTimer = Timer(const Duration(milliseconds: 1500), () async {
          _offlineDebounceTimer = null;
          final results = await _connectivity.checkConnectivity();
          final hasHardware = results.any(
            (r) =>
                r == ConnectivityResult.wifi ||
                r == ConnectivityResult.mobile ||
                r == ConnectivityResult.ethernet ||
                r == ConnectivityResult.vpn,
          );

          if (!hasHardware) {
            if (isConnectedNotifier.value) {
              isConnectedNotifier.value = false;
              debugPrint('[ConnectivityService] Connection status changed -> isConnected: false');
            }
            return;
          }

          try {
            final lookup = await InternetAddress.lookup('google.com')
                .timeout(const Duration(seconds: 3));
            final online = lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
            if (isConnectedNotifier.value != online) {
              isConnectedNotifier.value = online;
              debugPrint('[ConnectivityService] Connection status changed -> isConnected: $online');
            }
          } catch (_) {
            if (isConnectedNotifier.value) {
              isConnectedNotifier.value = false;
              debugPrint('[ConnectivityService] Connection status changed -> isConnected: false');
            }
          }
        });
      }
    }
  }

  /// Manually checks and returns whether the device has working internet.
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasHardware = results.any(
        (r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet ||
            r == ConnectivityResult.vpn,
      );

      if (!hasHardware) {
        _setConnected(false);
        return false;
      }

      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final online = lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
      _setConnected(online);
      return online;
    } catch (_) {
      _setConnected(false);
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _offlineDebounceTimer?.cancel();
    isConnectedNotifier.dispose();
  }
}
