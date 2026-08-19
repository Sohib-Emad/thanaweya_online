import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A selectable multiple-choice option tile for exam questions.
class ExamOptionTile extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final String letter;
  final VoidCallback onTap;

  const ExamOptionTile({
    super.key,
    required this.optionText,
    required this.isSelected,
    required this.letter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? NotebookColors.surfaceBright
              : NotebookColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? NotebookColors.green
                : NotebookColors.ink.withAlpha(45),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? NotebookColors.green
                    : NotebookColors.surfaceBright,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? NotebookColors.green
                      : NotebookColors.ink.withAlpha(60),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: NotebookText.strong(
                    13.sp,
                    color: isSelected ? Colors.white : NotebookColors.pencil,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                optionText,
                style: NotebookText.body(13.sp, color: NotebookColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
