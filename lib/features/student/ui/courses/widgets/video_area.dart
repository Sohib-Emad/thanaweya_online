import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thanaweya_online/core/widgets/dailymotion_player_widget.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/locked_overlay.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/upload_overlay.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/view_locked_overlay.dart';

/// A 16:9 video player area that switches between Dailymotion, YouTube, and
/// uploaded video sources, with subscription and view-limit overlays.
class VideoArea extends StatelessWidget {
  const VideoArea({
    super.key,
    required this.isCheckingSubscription,
    required this.isSubscribed,
    required this.viewLocked,
    required this.isDailymotion,
    required this.isYoutube,
    required this.activeUrl,
    required this.activeLessonId,
    required this.isUploadLoading,
    required this.onViewStarted,
    this.onPositionChanged,
    required this.youtubeController,
    required this.videoController,
    this.courseId = '',
    this.startSeconds = 0,
    this.maxWatchedPosition = Duration.zero,
    this.isFullscreen = false,
    this.onToggleFullscreen,
  });

  /// Callback for player position updates (Dailymotion, uploaded, YouTube).
  final void Function(Duration position, Duration duration)? onPositionChanged;

  /// Furthest watched position (for fast-forward prevention).
  final Duration maxWatchedPosition;

  /// Whether fullscreen is active.
  final bool isFullscreen;

  /// Fullscreen toggle callback.
  final VoidCallback? onToggleFullscreen;

  /// Whether the subscription status is still being verified.
  final bool isCheckingSubscription;

  /// Whether the student is subscribed to the course.
  final bool isSubscribed;

  /// Whether the view limit for this lesson has been exhausted.
  final bool viewLocked;

  /// Whether the current source is Dailymotion.
  final bool isDailymotion;

  /// Whether the current source is YouTube.
  final bool isYoutube;

  /// The video URL or ID.
  final String activeUrl;

  /// The active lesson ID.
  final String activeLessonId;

  /// Whether an uploaded video is still loading.
  final bool isUploadLoading;

  /// Called when the video starts playing (for view counting).
  final VoidCallback onViewStarted;

  /// YouTube player controller (null when not playing YouTube).
  final YoutubePlayerController? youtubeController;

  /// Video player controller (null when not playing uploaded video).
  final VideoPlayerController? videoController;

  /// Course ID passed through to the locked overlay.
  final String courseId;

  /// Resume position in seconds.
  final int startSeconds;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isCheckingSubscription) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (!isSubscribed) {
      return LockedOverlay(
        courseId: courseId,
        onSubscriptionChecked: () {},
      );
    }

    if (viewLocked) {
      return const ViewLockedOverlay(viewCount: 0, maxViews: 0);
    }

    if (isDailymotion) {
      return DailymotionPlayerWidget(
        key: ValueKey('$activeUrl-$startSeconds'),
        videoUrlOrId: activeUrl,
        autoPlay: true,
        startSeconds: startSeconds,
        onReady: onViewStarted,
        onProgress: onPositionChanged,
      );
    }

    if (isYoutube) {
      return _buildYoutubePlayer();
    }

    return _buildUploadPlayer();
  }

  Widget _buildYoutubePlayer() {
    if (youtubeController == null) return const SizedBox();
    return Stack(
      children: [
        YoutubePlayer(
          controller: youtubeController!,
          showVideoProgressIndicator: true,
          onReady: onViewStarted,
        ),
        if (!youtubeController!.value.isReady)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildUploadPlayer() {
    if (videoController == null) return const SizedBox();
    return Stack(
      children: [
        Positioned.fill(
          child: Center(child: VideoPlayer(videoController!)),
        ),
        if (isUploadLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
        else
          UploadOverlay(
            controller: videoController!,
            maxWatchedPosition: maxWatchedPosition,
            isFullscreen: isFullscreen,
            onToggleFullscreen: onToggleFullscreen,
          ),
      ],
    );
  }
}
