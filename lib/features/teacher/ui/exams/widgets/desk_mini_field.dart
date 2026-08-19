import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A compact text field used inside MCQ option rows.
class DeskMiniField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isCorrect;

  const DeskMiniField({
    super.key,
    required this.controller,
    required this.hint,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isCorrect
              ? DeskColors.primary.withAlpha(150)
              : DeskColors.line,
          width: isCorrect ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: DeskText.body(13.sp),
        cursorColor: DeskColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              DeskText.note(11.sp).copyWith(color: DeskColors.faint),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }
}
