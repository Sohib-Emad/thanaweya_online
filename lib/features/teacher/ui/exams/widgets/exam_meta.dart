import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A small inline metadata chip showing an icon and text.
class ExamMeta extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The descriptive text.
  final String text;

  const ExamMeta({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: DeskColors.muted),
        SizedBox(width: 4.w),
        Text(text, style: DeskText.note(11.sp)),
      ],
    );
  }
}
