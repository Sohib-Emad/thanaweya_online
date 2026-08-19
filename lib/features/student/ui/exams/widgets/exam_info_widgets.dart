import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Small stat item used in the exam header card (icon + value + label).
class ExamStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ExamStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: NotebookColors.green, size: 20.r),
        SizedBox(height: 6.h),
        Text(value, style: NotebookText.strong(13.sp)),
        SizedBox(height: 2.h),
        Text(label, style: NotebookText.note(10.sp)),
      ],
    );
  }
}

/// A single rule row shown in the exam rules section.
class ExamRuleItem extends StatelessWidget {
  final String title;
  final String description;

  const ExamRuleItem({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: NotebookText.strong(12.sp, color: NotebookColors.marginRed),
        ),
        SizedBox(height: 2.h),
        Text(
          description,
          style: NotebookText.body(11.sp).copyWith(height: 1.4),
        ),
      ],
    );
  }
}

/// Displays remaining attempts or locked state for an exam.
class AttemptsInfoCard extends StatelessWidget {
  final bool locked;
  final int remaining;
  final int maxAttempts;
  final String lockedTitle;
  final String unlockedTitle;
  final String lockedMessage;
  final String unlockedMessage;

  const AttemptsInfoCard({
    super.key,
    required this.locked,
    required this.remaining,
    required this.maxAttempts,
    required this.lockedTitle,
    required this.unlockedTitle,
    required this.lockedMessage,
    required this.unlockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 40,
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Icon(
            locked ? Icons.lock_rounded : Icons.repeat_rounded,
            color: locked ? NotebookColors.marginRed : NotebookColors.green,
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locked ? lockedTitle : unlockedTitle,
                  style: NotebookText.strong(
                    13.sp,
                    color: locked ? NotebookColors.marginRed : NotebookColors.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  locked ? lockedMessage : unlockedMessage,
                  style: NotebookText.note(10.5.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
