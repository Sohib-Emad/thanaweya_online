import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A card displaying a single exam attempt with number, date, score,
/// and pass/fail badge.
class AttemptCard extends StatelessWidget {
  final int index;
  final int score;
  final int totalPoints;
  final String? submittedAt;
  final String Function(String iso) dateFormatter;

  const AttemptCard({
    super.key,
    required this.index,
    required this.score,
    required this.totalPoints,
    this.submittedAt,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent =
        totalPoints > 0 ? (score / totalPoints * 100).toInt() : 0;
    final isPass = percent >= 50;
    final accent = isPass ? NotebookColors.green : NotebookColors.marginRed;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 64,
        marginTab: isPass,
        child: Row(
          children: [
            _AttemptIndexBadge(index: index, accent: accent),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.attemptNumber(index),
                    style: NotebookText.heading(13.sp),
                  ),
                  if (submittedAt != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      dateFormatter(submittedAt!),
                      style: NotebookText.note(10.sp),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),
            _AttemptScoreColumn(
              score: score,
              totalPoints: totalPoints,
              percent: percent,
              isPass: isPass,
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptIndexBadge extends StatelessWidget {
  final int index;
  final Color accent;

  const _AttemptIndexBadge({required this.index, required this.accent});

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
          '$index',
          style: NotebookText.strong(14.sp, color: accent),
        ),
      ),
    );
  }
}

class _AttemptScoreColumn extends StatelessWidget {
  final int score;
  final int totalPoints;
  final int percent;
  final bool isPass;
  final Color accent;

  const _AttemptScoreColumn({
    required this.score,
    required this.totalPoints,
    required this.percent,
    required this.isPass,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$score / $totalPoints',
          style: NotebookText.strong(13.sp, color: accent),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: accent.withAlpha(24),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            isPass ? l10n.passedPercent(percent) : '$percent%',
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}
