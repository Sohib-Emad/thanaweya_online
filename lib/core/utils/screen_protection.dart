import 'package:flutter/services.dart';

/// Protects sensitive screens (e.g. video lessons) from screenshots and
/// screen recording.
///
/// On Android this sets the `FLAG_SECURE` window flag — it blocks both
/// screenshots and screen recording of the app window while enabled.
/// (iOS does not expose a public API to prevent screenshots/recording, so
/// the call is a no-op there.)
class ScreenProtection {
  ScreenProtection._();

  static const MethodChannel _channel =
      MethodChannel('thanaweya_online/screen_protection');

  /// Blocks screenshots + screen recording for the current activity window.
  static Future<void> enable() async {
    try {
      await _channel.invokeMethod<void>('enable');
    } catch (_) {
      // Not supported on this platform — ignore.
    }
  }

  /// Removes the screenshot/recording block.
  static Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('disable');
    } catch (_) {
      // Not supported on this platform — ignore.
    }
  }
}
