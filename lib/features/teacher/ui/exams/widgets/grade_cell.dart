import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A single grade statistic cell showing an icon, value, and label.
class GradeCell extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The descriptive label below the value.
  final String label;

  /// The formatted value to display.
  final String value;

  /// The accent color for the icon and value.
  final Color color;

  const GradeCell({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.r, color: color),
              SizedBox(width: 4.w),
              Text(
                value,
                style: DeskText.strong(13.sp, color: color),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(label, style: DeskText.note(9.5.sp)),
        ],
      ),
    );
  }
}
