import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_results_helpers.dart';

/// Podium section showing the top three performing students.
///
/// Renders medal-colored cards with student names and best percentage scores.
class TopPerformersSection extends StatelessWidget {
  const TopPerformersSection({
    super.key,
    required this.groups,
  });

  final Map<String, List<Map<String, dynamic>>> groups;

  static const _medalColors = [
    Color(0xFFF59E0B),
    Color(0xFF94A3B8),
    Color(0xFFD97706),
  ];

  @override
  Widget build(BuildContext context) {
    final topList = groups.entries.take(3).toList();
    if (topList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B), size: 20.r),
              SizedBox(width: 8.w),
              Text('لوحة أوائل الطلاب المتفوقين', style: DeskText.strong(14.sp)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (int i = 0; i < topList.length; i++) ...[
                if (i > 0) SizedBox(width: 8.w),
                _PerformerCard(
                  name: ExamResultsHelpers.studentName(topList[i].value),
                  percent: ExamResultsHelpers.bestPercent(topList[i].value),
                  color: _medalColors[i],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformerCard extends StatelessWidget {
  const _PerformerCard({
    required this.name,
    required this.percent,
    required this.color,
  });

  final String name;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withAlpha(60), width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.workspace_premium_rounded, color: color, size: 26.r),
            SizedBox(height: 4.h),
            Text(name, style: DeskText.strong(11.5.sp),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 2.h),
            Text('${percent.toStringAsFixed(0)}%',
                style: DeskText.heading(13.sp, color: color)),
          ],
        ),
      ),
    );
  }
}
