import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Comprehensive 4-tile stats summary grid showing courses count, exam average,
/// lesson attendance rate, and total study minutes.
class ReportStatsSummary extends StatelessWidget {
  const ReportStatsSummary({
    super.key,
    required this.examAvg,
    required this.lessonRate,
    this.coursesCount = 0,
    this.totalWatchedMinutes = 0,
    this.examsCount = 0,
  });

  final double examAvg;
  final double lessonRate;
  final int coursesCount;
  final int totalWatchedMinutes;
  final int examsCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF0284C7),
                label: 'الكورسات المشترك بها',
                value: '$coursesCount كورس',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTile(
                icon: Icons.analytics_rounded,
                color: const Color(0xFF7C3AED),
                label: 'متوسط الامتحانات',
                value: examsCount > 0 ? '${examAvg.toStringAsFixed(1)}%' : 'لا توجد بعد',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.play_circle_fill_rounded,
                color: const Color(0xFF059669),
                label: 'نسبة حضور الحصص',
                value: '${lessonRate.toStringAsFixed(1)}%',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTile(
                icon: Icons.timelapse_rounded,
                color: const Color(0xFFD97706),
                label: 'وقت الاستماع الفعلي',
                value: totalWatchedMinutes > 0 ? '$totalWatchedMinutes دقيقة' : '—',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.r, color: color),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DeskText.note(9.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 1.h),
                Text(value, style: DeskText.strong(12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
