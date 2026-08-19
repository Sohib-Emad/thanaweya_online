import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Bottom action buttons for the teacher enrollment form.
class TeacherFormBottomBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback? onSubmit;
  final bool isLoading;

  const TeacherFormBottomBar({
    super.key,
    required this.currentStep,
    required this.onNext,
    required this.onPrev,
    this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStep == 0) {
      return DeskPrimaryButton(
        label: 'التالي',
        icon: Icons.arrow_back_rounded,
        onPressed: onNext,
      );
    }
    if (currentStep == 4) {
      return Row(
        children: [
          Expanded(
            child: DeskOutlineButton(
              label: 'السابق',
              icon: Icons.arrow_forward_rounded,
              color: DeskColors.muted,
              onPressed: onPrev,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: DeskPrimaryButton(
              label: 'إرسال طلب التفعيل وتم الدفع',
              icon: Icons.check_circle_outline_rounded,
              loading: isLoading,
              onPressed: isLoading ? null : onSubmit,
            ),
          ),
        ],
      );
    }
    if (currentStep == 3) {
      return Row(
        children: [
          Expanded(
            child: DeskOutlineButton(
              label: 'السابق',
              icon: Icons.arrow_forward_rounded,
              color: DeskColors.muted,
              onPressed: onPrev,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: DeskPrimaryButton(
              label: 'متابعة للدفع',
              icon: Icons.arrow_back_rounded,
              onPressed: onNext,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: DeskOutlineButton(
            label: 'السابق',
            icon: Icons.arrow_forward_rounded,
            color: DeskColors.muted,
            onPressed: onPrev,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: DeskPrimaryButton(
            label: 'التالي',
            icon: Icons.arrow_back_rounded,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}
