import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A selectable tile used for true/false answer options.
class AnswerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const AnswerTile({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color:
              selected ? accent.withAlpha(26) : DeskColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? accent : DeskColors.line,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: DeskText.strong(15.sp,
                color: selected ? accent : DeskColors.muted),
          ),
        ),
      ),
    );
  }
}
