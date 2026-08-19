import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';

/// Custom playback overlay for uploaded (non-YouTube, non-Dailymotion) videos.
///
/// Provides a play/pause button, a seek slider, and duration labels.
class UploadOverlay extends StatelessWidget {
  const UploadOverlay({
    super.key,
    required this.controller,
  });

  /// The underlying [VideoPlayerController] driving playback.
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final position = value.position;
        final duration = value.duration;
        final progress = duration.inMilliseconds == 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PlayPauseButton(
              isPlaying: value.isPlaying,
              onToggle: () {
                value.isPlaying ? controller.pause() : controller.play();
              },
            ),
            _SeekBar(
              position: position,
              duration: duration,
              progress: progress,
              onSeek: (v) {
                if (duration.inMilliseconds == 0) return;
                final target = Duration(
                  milliseconds: (duration.inMilliseconds * v).round(),
                );
                controller.seekTo(target);
              },
            ),
            SizedBox(height: 4.h),
          ],
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.onToggle,
  });

  final bool isPlaying;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          margin: EdgeInsets.all(8.r),
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(210),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: const Color(0xFF0F172A),
            size: 26.r,
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({
    required this.position,
    required this.duration,
    required this.progress,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final double progress;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          Text(
            Formatters.formatDuration(position.inSeconds),
            style: NotebookText.note(10.sp, color: Colors.white.withAlpha(230)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                activeTrackColor: NotebookColors.green,
                inactiveTrackColor: Colors.white.withAlpha(100),
                thumbColor: NotebookColors.green,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(value: progress, onChanged: onSeek),
            ),
          ),
          Text(
            Formatters.formatDuration(duration.inSeconds),
            style: NotebookText.note(10.sp, color: Colors.white.withAlpha(230)),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
