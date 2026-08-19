import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A single icon + label + value info row used in teacher detail cards.
class TeacherInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const TeacherInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: NotebookColors.pencil, size: 16.r),
          SizedBox(width: 10.w),
          Text('$label: ', style: NotebookText.note(11.sp)),
          Expanded(child: Text(value, style: NotebookText.body(11.sp))),
        ],
      ),
    );
  }
}
