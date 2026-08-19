import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/stat_cell.dart';

/// Displays a row of key student statistics: enrolled courses,
/// total lessons, completed lessons, and overall completion percentage.
class StudentStatsCard extends StatelessWidget {
  final int coursesCount;
  final int totalLessons;
  final int completedLessons;
  final int completionPercent;

  const StudentStatsCard({
    super.key,
    required this.coursesCount,
    required this.totalLessons,
    required this.completedLessons,
    required this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      child: Column(
        children: [
          Row(
            children: [
              StatCell(
                label: 'الكورسات المشترك بها',
                value: '$coursesCount',
                accent: DeskColors.primary,
                icon: Icons.menu_book_rounded,
              ),
              _divider(),
              StatCell(
                label: 'إجمالي الدروس',
                value: '$totalLessons',
                accent: DeskColors.info,
                icon: Icons.ondemand_video_rounded,
              ),
              _divider(),
              StatCell(
                label: 'دروس مكتملة',
                value: '$completedLessons',
                accent: DeskColors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              _divider(),
              StatCell(
                label: 'نسبة الإنجاز',
                value: '$completionPercent%',
                accent: DeskColors.accent,
                icon: Icons.pie_chart_outline_rounded,
              ),
            ],
          ),
          if (totalLessons > 0) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: (completionPercent / 100).clamp(0.0, 1.0),
                minHeight: 7.h,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionPercent >= 100
                      ? const Color(0xFF059669)
                      : const Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36.h,
        color: DeskColors.line,
      );
}
