class DailymotionUtils {
  /// Extracts the Dailymotion video ID from any URL or raw ID string.
  /// Supports:
  /// - https://www.dailymotion.com/video/x8yyyy
  /// - https://dai.ly/x8yyyy
  /// - https://www.dailymotion.com/embed/video/x8yyyy
  /// - https://geo.dailymotion.com/player/...html?video=x8yyyy
  /// - Raw ID: x8yyyy or k123...
  static String? extractVideoId(String? input) {
    if (input == null) return null;
    final clean = input.trim();
    if (clean.isEmpty) return null;

    // Check for standard query parameter: ?video=x8yyyy
    if (clean.contains('video=')) {
      final uri = Uri.tryParse(clean);
      if (uri != null) {
        final videoParam = uri.queryParameters['video'];
        if (videoParam != null && videoParam.isNotEmpty) {
          return videoParam;
        }
      }
    }

    // Match regex for dailymotion patterns: dai.ly/x8xyz or dailymotion.com/video/x8xyz
    final regExp = RegExp(
      r'(?:dailymotion\.com\/(?:video|embed\/video)\/|dai\.ly\/)([a-zA-Z0-9]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(clean);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // If it has no slashes or dots, it's probably already a pure Dailymotion video ID
    if (!clean.contains('/') && !clean.contains('.')) {
      return clean;
    }

    // Fallback: extract last path segment if clean
    try {
      final uri = Uri.tryParse(clean);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.isNotEmpty && !last.contains('.')) {
          return last;
        }
      }
    } catch (_) {}

    return clean;
  }

  /// Returns true if the string looks like a Dailymotion URL or ID.
  static bool isDailymotionUrl(String? input) {
    if (input == null) return false;
    final lower = input.trim().toLowerCase();
    return lower.contains('dailymotion.com') ||
        lower.contains('dai.ly') ||
        lower.startsWith('x') && lower.length >= 6 && lower.length <= 10;
  }

  /// Returns the direct iframe embed URL for Dailymotion.
  static String getEmbedUrl(String urlOrId, {bool autoplay = true}) {
    final id = extractVideoId(urlOrId) ?? urlOrId.trim();
    final auto = autoplay ? 1 : 0;
    return 'https://www.dailymotion.com/embed/video/$id?autoplay=$auto&ui-logo=0&ui-start-screen-info=0&sharing-enable=0';
  }

  /// Generates the HTML player page for InAppWebView embedding with fullscreen and responsive sizing.
  static String getEmbedHtml(String urlOrId, {bool autoplay = true}) {
    final id = extractVideoId(urlOrId) ?? urlOrId.trim();
    final auto = autoplay ? 1 : 0;
    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .video-container {
      position: relative;
      width: 100%;
      height: 100%;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe
      src="https://www.dailymotion.com/embed/video/$id?autoplay=$auto&ui-logo=0&ui-start-screen-info=0&sharing-enable=0&queue-autoplay-next=0"
      allow="autoplay; fullscreen; picture-in-picture; web-share; encrypted-media"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';
  }
}
