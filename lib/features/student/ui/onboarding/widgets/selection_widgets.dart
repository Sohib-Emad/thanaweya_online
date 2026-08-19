import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Animated checkbox used for multi-select lists.
class NotebookCheckbox extends StatelessWidget {
  final bool isSelected;

  const NotebookCheckbox({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24.r,
      height: 24.r,
      decoration: BoxDecoration(
        color: isSelected
            ? NotebookColors.green
            : NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isSelected
              ? NotebookColors.green
              : NotebookColors.ink.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
          : null,
    );
  }
}

/// A row with checkbox, label, and optional pin indicator.
class SelectionRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final TextStyle? labelStyle;

  const SelectionRow({
    super.key,
    required this.label,
    required this.isSelected,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NotebookCheckbox(isSelected: isSelected),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            label,
            style: labelStyle ??
                NotebookText.body(
                  13.5.sp,
                  color: isSelected
                      ? NotebookColors.ink
                      : NotebookColors.pencil,
                ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.push_pin_rounded,
            color: NotebookColors.marginRed.withAlpha(160),
            size: 15.r,
          ),
      ],
    );
  }
}
