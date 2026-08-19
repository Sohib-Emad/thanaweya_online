import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Displays the exam result with score, percentage, and pass/fail status
/// on a notebook-styled card.
class ResultPaperCard extends StatelessWidget {
  final int score;
  final int total;
  final bool isPass;

  const ResultPaperCard({
    super.key,
    required this.score,
    required this.total,
    required this.isPass,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = total > 0 ? (score / total) * 100 : 0.0;
    final accent = isPass ? NotebookColors.green : NotebookColors.marginRed;

    return NotebookCard(
      ruled: true,
      ruledStartY: 132,
      padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 26.r),
      child: Column(
        children: [
          NotebookStamp(label: l10n.resultStamp),
          SizedBox(height: 14.h),
          Text(
            '$score / $total',
            style: NotebookText.heading(40.sp, color: accent),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: accent.withAlpha(30),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              l10n.percentage(percent.toStringAsFixed(0)),
              style: NotebookText.strong(13.sp, color: accent),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            isPass ? l10n.examPassed : l10n.examFailed,
            textAlign: TextAlign.center,
            style: NotebookText.heading(18.sp),
          ),
        ],
      ),
    );
  }
}
