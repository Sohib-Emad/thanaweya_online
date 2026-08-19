import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Single step dot in the enrollment stepper progress bar.
class StepItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const StepItem({
    super.key,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            color: isCompleted
                ? DeskColors.primary
                : isActive
                    ? DeskColors.primary.withAlpha(30)
                    : DeskColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? DeskColors.primary : DeskColors.faint,
              width: isActive ? 1.8 : 1.2,
            ),
          ),
          child: isCompleted
              ? Icon(
                  Icons.check_rounded,
                  color: DeskColors.onPrimary,
                  size: 15.r,
                )
              : null,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: DeskText.strong(10.sp,
              color: isActive ? DeskColors.primary : DeskColors.faint),
        ),
      ],
    );
  }
}

/// Connector line between step dots in the stepper.
class StepConnector extends StatelessWidget {
  final bool isActive;
  const StepConnector({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 20.h),
        color: isActive
            ? DeskColors.primary.withAlpha(160)
            : DeskColors.faint.withAlpha(90),
      ),
    );
  }
}
