import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Single teaching-mode option card (online / center / both).
class TeachingModeOption extends StatelessWidget {
  final String modeKey;
  final String label;
  final IconData iconData;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const TeachingModeOption({
    super.key,
    required this.modeKey,
    required this.label,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(modeKey);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? DeskColors.primary.withAlpha(26)
                : DeskColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? DeskColors.primary : DeskColors.line,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 20.r,
                color: isSelected ? DeskColors.primary : DeskColors.muted,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: DeskText.strong(12.sp,
                    color:
                        isSelected ? DeskColors.primary : DeskColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
