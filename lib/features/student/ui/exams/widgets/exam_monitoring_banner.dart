import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Anti-cheat monitoring banner shown at the top of the exam screen.
class ExamMonitoringBanner extends StatelessWidget {
  final String message;

  const ExamMonitoringBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: NotebookColors.marginRed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white, size: 15.r),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              message,
              style: NotebookText.strong(10.5.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
