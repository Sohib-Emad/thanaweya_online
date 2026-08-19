import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A tappable tile representing a single exam attached to a lesson.
class LessonExamTile extends StatelessWidget {
  const LessonExamTile({
    super.key,
    required this.exam,
    required this.onTap,
  });

  /// Raw exam map from Supabase.
  final Map<String, dynamic> exam;

  /// Called when the user taps the tile (will be null if locked).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final examTitle =
        exam['title'] as String? ?? context.l10n.lessonExam;
    final duration = exam['duration_minutes'] as int? ?? 0;
    final used = exam['attempts_used'] as int? ?? 0;
    final maxAttempts = exam['max_attempts'] as int? ?? 3;
    final locked = used >= maxAttempts;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 24,
        marginTab: !locked,
        onTap: locked
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock_rounded : Icons.quiz_rounded,
              color:
                  locked ? NotebookColors.marginRed : NotebookColors.green,
              size: 22.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examTitle,
                    style: NotebookText.body(12.5.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    locked
                        ? context.l10n.attemptsExhausted
                        : context.l10n.examMeta(duration, used, maxAttempts),
                    style: NotebookText.note(10.sp),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color:
                  locked ? NotebookColors.pencil : NotebookColors.green,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
