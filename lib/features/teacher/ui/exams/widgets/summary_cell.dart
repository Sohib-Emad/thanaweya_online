import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Single stat cell inside the results summary bar.
///
/// Displays an icon, numeric value, and label text in a column layout
/// used by [ResultsSummaryBar].
class SummaryCell extends StatelessWidget {
  const SummaryCell({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.r, color: color),
              SizedBox(width: 4.w),
              Text(value, style: DeskText.heading(16.sp, color: color)),
            ],
          ),
          SizedBox(height: 2.h),
          Text(label, style: DeskText.note(10.sp)),
        ],
      ),
    );
  }
}
