import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A card displaying a single grade entry with percentage, exam title,
/// and score.
class GradeCard extends StatelessWidget {
  final String examTitle;
  final int score;
  final int totalPoints;

  const GradeCard({
    super.key,
    required this.examTitle,
    required this.score,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    final percent =
        totalPoints > 0 ? (score / totalPoints * 100).toInt() : 0;
    final isPass = percent >= 50;
    final accent = isPass ? NotebookColors.green : NotebookColors.marginRed;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 64,
        child: Row(
          children: [
            _PercentBadge(percent: percent, accent: accent),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examTitle,
                    style: NotebookText.heading(13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$score / $totalPoints',
                    style: NotebookText.note(11.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  final int percent;
  final Color accent;

  const _PercentBadge({required this.percent, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: accent.withAlpha(24),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent.withAlpha(90), width: 1.2),
      ),
      child: Center(
        child: Text(
          '$percent%',
          style: NotebookText.strong(12.sp, color: accent),
        ),
      ),
    );
  }
}
