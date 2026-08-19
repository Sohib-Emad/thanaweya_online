import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A styled chip displaying the remaining exam time with urgency coloring.
class ExamTimerChip extends StatelessWidget {
  final int secondsRemaining;
  final String formattedTime;

  const ExamTimerChip({
    super.key,
    required this.secondsRemaining,
    required this.formattedTime,
  });

  bool get _isUrgent => secondsRemaining < 300;

  @override
  Widget build(BuildContext context) {
    final urgent = _isUrgent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: urgent ? NotebookColors.marginRed : NotebookColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: NotebookColors.marginRed, width: 1.4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: urgent ? Colors.white : NotebookColors.marginRed,
            size: 14.r,
          ),
          SizedBox(width: 4.w),
          Text(
            formattedTime,
            style: NotebookText.strong(
              13.sp,
              color: urgent ? Colors.white : NotebookColors.marginRed,
            ),
          ),
        ],
      ),
    );
  }
}
