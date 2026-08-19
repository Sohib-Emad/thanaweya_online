import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Two-column stats summary showing exam average and lesson attendance rate.
class ReportStatsSummary extends StatelessWidget {
  const ReportStatsSummary({
    super.key,
    required this.examAvg,
    required this.lessonRate,
  });

  final double examAvg;
  final double lessonRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPill(
            icon: Icons.analytics_rounded,
            color: DeskColors.primary,
            label: 'متوسط الامتحانات',
            value: '${examAvg.toStringAsFixed(1)}%',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildPill(
            icon: Icons.ondemand_video_rounded,
            color: DeskColors.info,
            label: 'نسبة الحضور',
            value: '${lessonRate.toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: color),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DeskText.note(10.5.sp)),
              Text(value, style: DeskText.strong(13.5.sp)),
            ],
          ),
        ],
      ),
    );
  }
}
