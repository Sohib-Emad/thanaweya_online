import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_summary.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/grade_cell.dart';

/// Displays the grades summary section inside an exam card.
///
/// Shows either an empty-state banner or a row of [GradeCell] widgets.
class ExamGradesSection extends StatelessWidget {
  /// The grades summary data.
  final ExamGradesSummary grades;

  const ExamGradesSection({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    if (grades.participants == 0) {
      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: DeskColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.how_to_reg_outlined, size: 16.r, color: DeskColors.faint),
            SizedBox(width: 8.w),
            Text('لم يشارك أحد بعد', style: DeskText.note(11.sp)),
          ],
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: DeskColors.primarySoft,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: DeskColors.primary.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          GradeCell(icon: Icons.people_alt_outlined, label: 'مشارك', value: '${grades.participants}', color: DeskColors.info),
          Container(width: 1, height: 22.h, color: DeskColors.primary.withAlpha(60)),
          GradeCell(icon: Icons.stars_outlined, label: 'أفضل نتيجة', value: '${grades.bestPercent.toStringAsFixed(0)}%', color: DeskColors.success),
          Container(width: 1, height: 22.h, color: DeskColors.primary.withAlpha(60)),
          GradeCell(icon: Icons.analytics_outlined, label: 'المتوسط', value: grades.averagePercent.toStringAsFixed(1), color: DeskColors.accent),
        ],
      ),
    );
  }
}
