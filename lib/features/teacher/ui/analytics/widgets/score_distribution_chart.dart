import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/analytics/widgets/score_bar.dart';

/// Score distribution chart showing student grade breakdown
/// across four performance levels.
class ScoreDistributionChart extends StatelessWidget {
  const ScoreDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 18.r, color: const Color(0xFF0284C7)),
              SizedBox(width: 6.w),
              Text('توزيع الدرجات والمستويات للطلاب',
                  style: DeskText.heading(13.sp)),
            ],
          ),
          SizedBox(height: 12.h),
          const ScoreBar(
              label: 'ممتاز (90% - 100%)',
              ratio: 0.45,
              color: Color(0xFF0284C7),
              textValue: '45%'),
          SizedBox(height: 8.h),
          const ScoreBar(
              label: 'جيد جداً (80% - 89%)',
              ratio: 0.30,
              color: Color(0xFF0EA5E9),
              textValue: '30%'),
          SizedBox(height: 8.h),
          const ScoreBar(
              label: 'جيد (65% - 79%)',
              ratio: 0.15,
              color: Color(0xFFF59E0B),
              textValue: '15%'),
          SizedBox(height: 8.h),
          const ScoreBar(
              label: 'يحتاج تحسين (< 65%)',
              ratio: 0.10,
              color: Color(0xFFE11D48),
              textValue: '10%'),
        ],
      ),
    );
  }
}
