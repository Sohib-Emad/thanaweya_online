import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/analytics/widgets/score_bar.dart';

/// Score distribution chart showing real student grade breakdown
/// across four performance levels.
class ScoreDistributionChart extends StatelessWidget {
  final double excellentRatio;
  final String excellentText;
  final double veryGoodRatio;
  final String veryGoodText;
  final double goodRatio;
  final String goodText;
  final double needsImprovementRatio;
  final String needsImprovementText;

  const ScoreDistributionChart({
    super.key,
    this.excellentRatio = 0.45,
    this.excellentText = '45%',
    this.veryGoodRatio = 0.30,
    this.veryGoodText = '30%',
    this.goodRatio = 0.15,
    this.goodText = '15%',
    this.needsImprovementRatio = 0.10,
    this.needsImprovementText = '10%',
  });

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
                  size: 20.r, color: const Color(0xFF0284C7)),
              SizedBox(width: 8.w),
              Text('توزيع الدرجات والمستويات للطلاب',
                  style: DeskText.heading(13.5.sp)),
            ],
          ),
          SizedBox(height: 14.h),
          ScoreBar(
            label: 'ممتاز (90% - 100%)',
            ratio: excellentRatio.clamp(0.0, 1.0),
            color: const Color(0xFF0284C7),
            textValue: excellentText,
          ),
          SizedBox(height: 10.h),
          ScoreBar(
            label: 'جيد جداً (80% - 89%)',
            ratio: veryGoodRatio.clamp(0.0, 1.0),
            color: const Color(0xFF0EA5E9),
            textValue: veryGoodText,
          ),
          SizedBox(height: 10.h),
          ScoreBar(
            label: 'جيد (65% - 79%)',
            ratio: goodRatio.clamp(0.0, 1.0),
            color: const Color(0xFFF59E0B),
            textValue: goodText,
          ),
          SizedBox(height: 10.h),
          ScoreBar(
            label: 'يحتاج تحسين (< 65%)',
            ratio: needsImprovementRatio.clamp(0.0, 1.0),
            color: const Color(0xFFE11D48),
            textValue: needsImprovementText,
          ),
        ],
      ),
    );
  }
}
