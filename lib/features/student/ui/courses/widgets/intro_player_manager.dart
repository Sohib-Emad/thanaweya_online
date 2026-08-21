import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';

/// Manages the lifecycle of intro-video controllers (YouTube, Dailymotion, or generic).
class IntroPlayerManager {
  YoutubePlayerController? youtubeController;
  VideoPlayerController? videoController;
  String? _initializedUrl;

  bool _isDailymotion(String url, String sourceType) {
    return sourceType.toLowerCase() == 'dailymotion' || DailymotionUtils.isDailymotionUrl(url);
  }

  bool _isYouTube(String url, String sourceType) {
    return sourceType.toLowerCase() == 'youtube' || url.contains('youtube') || url.contains('youtu.be');
  }

  /// Initializes the appropriate player for [url] given its [sourceType].
  /// Re-initializes only when the URL changes.
  void init(String url, String sourceType, {VoidCallback? onReady}) {
    if (_initializedUrl == url || url.isEmpty) return;
    _initializedUrl = url;
    dispose();

    if (_isDailymotion(url, sourceType)) {
      onReady?.call();
    } else if (_isYouTube(url, sourceType)) {
      final videoId = YoutubePlayer.convertUrlToId(url) ?? url.trim();
      youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
        ),
      );
    } else {
      try {
        videoController = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize().then((_) => onReady?.call());
      } catch (e) {
        debugPrint('[IntroPlayerManager] media url error: $e');
      }
    }
  }

  /// Disposes both controllers safely.
  void dispose() {
    final yt = youtubeController;
    if (yt != null) {
      try { yt.dispose(); } catch (_) {}
    }
    videoController?.dispose();
    youtubeController = null;
    videoController = null;
  }

  /// Whether the URL is a Dailymotion source.
  bool isDailymotion(String url, String sourceType) => _isDailymotion(url, sourceType);

  /// Whether the URL is a YouTube source.
  bool isYouTube(String url, String sourceType) => _isYouTube(url, sourceType);
}
