import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_cover_placeholder.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/embedded_intro_player.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// The top cover area with intro video or cover image, back button, and subject badge.
class CourseCoverSection extends StatelessWidget {
  final String introVideoUrl;
  final String introVideoSourceType;
  final String coverUrl;
  final String subjectName;
  final YoutubePlayerController? youtubeController;
  final VideoPlayerController? videoController;
  final VoidCallback onBack;

  const CourseCoverSection({
    super.key,
    required this.introVideoUrl,
    required this.introVideoSourceType,
    required this.coverUrl,
    required this.subjectName,
    required this.onBack,
    this.youtubeController,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 210.h,
      width: double.infinity,
      color: NotebookColors.ink,
      child: Stack(
        children: [
          if (introVideoUrl.isNotEmpty)
            Positioned.fill(
              child: EmbeddedIntroPlayer(
                url: introVideoUrl,
                sourceType: introVideoSourceType,
                youtubeController: youtubeController,
                videoController: videoController,
              ),
            )
          else if (coverUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => CourseCoverPlaceholder(color: NotebookColors.ink, subject: subjectName),
                errorWidget: (_, __, ___) => CourseCoverPlaceholder(color: NotebookColors.ink, subject: subjectName),
              ),
            )
          else
            Positioned.fill(child: CourseCoverPlaceholder(color: NotebookColors.ink, subject: subjectName)),
          Positioned(
            top: 18.h,
            right: 16.w,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NotebookColors.marginRed.withAlpha(140),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: NotebookColors.marginRed,
                  size: 20.r,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: NotebookColors.surfaceBright,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: NotebookColors.ink.withAlpha(40)),
              ),
              child: Text(
                subjectName.isEmpty
                    ? l10n.videoLesson
                    : l10n.videoOfSubject(subjectName),
                style: NotebookText.strong(11.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
