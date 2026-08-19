import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_results_helpers.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/summary_cell.dart';

/// Summary bar showing student count, best score, and average.
class ResultsSummaryBar extends StatelessWidget {
  const ResultsSummaryBar({super.key, required this.groups});

  final Map<String, List<Map<String, dynamic>>> groups;

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      accent: DeskColors.primary,
      child: Row(
        children: [
          SummaryCell(icon: Icons.people_alt_outlined, label: 'إجمالي المشتركين',
              value: '${groups.length}', color: DeskColors.info),
          Container(width: 1, height: 30.h, color: DeskColors.line),
          SummaryCell(icon: Icons.stars_outlined, label: 'أعلى نسبة نجاح',
              value: '${ExamResultsHelpers.bestScore(groups).toStringAsFixed(0)}%',
              color: DeskColors.accent),
          Container(width: 1, height: 30.h, color: DeskColors.line),
          SummaryCell(icon: Icons.analytics_outlined, label: 'المتوسط العام',
              value: ExamResultsHelpers.averageScore(groups).toStringAsFixed(1),
              color: DeskColors.success),
        ],
      ),
    );
  }
}
