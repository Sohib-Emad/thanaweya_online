import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';
import 'package:thanaweya_online/core/widgets/dailymotion_player_widget.dart';

/// Plays the intro video embedded inside the course cover area.
class EmbeddedIntroPlayer extends StatelessWidget {
  final String url;
  final String sourceType;
  final YoutubePlayerController? youtubeController;
  final VideoPlayerController? videoController;

  const EmbeddedIntroPlayer({
    super.key,
    required this.url,
    required this.sourceType,
    this.youtubeController,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final isDm = sourceType.toLowerCase() == 'dailymotion' ||
        DailymotionUtils.isDailymotionUrl(url);

    if (isDm) {
      return DailymotionPlayerWidget(
        videoUrlOrId: url,
        autoPlay: false,
      );
    }

    final isYt = sourceType.toLowerCase() == 'youtube' ||
        url.contains('youtube') ||
        url.contains('youtu.be');

    if (isYt && youtubeController != null) {
      return YoutubePlayer(
        controller: youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: NotebookColors.green,
      );
    }

    if (videoController != null && videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: VideoPlayer(videoController!),
      );
    }

    return Center(
      child: CircularProgressIndicator(color: NotebookColors.green),
    );
  }
}
