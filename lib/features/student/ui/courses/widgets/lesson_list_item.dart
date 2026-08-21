import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// A tappable tile representing a single lesson in the course list with locked state support.
class LessonListItem extends StatelessWidget {
  const LessonListItem({
    super.key,
    required this.lesson,
    required this.index,
    required this.isActive,
    required this.isCompleted,
    this.isLocked = false,
    required this.onTap,
  });

  /// The lesson model to display.
  final LessonModel lesson;

  /// Zero-based index in the lessons list.
  final int index;

  /// Whether this lesson is currently playing.
  final bool isActive;

  /// Whether the student has completed this lesson.
  final bool isCompleted;

  /// Whether this lesson is locked (requires exam/previous lesson).
  final bool isLocked;

  /// Called when the user taps the tile.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 20,
        marginTab: isActive || isCompleted,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Row(
          children: [
            Icon(
              isLocked
                  ? Icons.lock_outline_rounded
                  : isActive
                      ? Icons.play_circle_fill_rounded
                      : isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.play_circle_outline_rounded,
              color: isLocked
                  ? NotebookColors.pencil.withAlpha(150)
                  : (isActive || isCompleted
                      ? NotebookColors.green
                      : NotebookColors.pencil),
              size: 22.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                '${index + 1}. ${lesson.title}',
                style: NotebookText.body(
                  12.sp,
                  color: isLocked
                      ? NotebookColors.pencil
                      : (isActive ? NotebookColors.green : NotebookColors.ink),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLocked)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  '🔒 مغلق',
                  style: NotebookText.note(10.5.sp,
                      color: NotebookColors.marginRed),
                ),
              )
            else if (lesson.durationSeconds != null)
              Text(
                Formatters.formatDurationMinutes(
                  (lesson.durationSeconds! / 60).ceil(),
                ),
                style: NotebookText.note(11.sp),
              ),
          ],
        ),
      ),
    );
  }
}
