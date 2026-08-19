import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/widgets.dart';

/// AppBar and step indicator for the teacher form screen.
class TeacherFormHeader extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onPrev;

  const TeacherFormHeader({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: Row(children: [
            if (currentStep > 0)
              GestureDetector(onTap: onPrev, child: Container(
                width: 40.r, height: 40.r,
                decoration: const BoxDecoration(color: DeskColors.primarySoft, shape: BoxShape.circle),
                child: Icon(Icons.arrow_forward_rounded, color: DeskColors.primary, size: 20.r)))
            else
              GestureDetector(onTap: onBack, child: Container(
                width: 40.r, height: 40.r,
                decoration: BoxDecoration(color: DeskColors.surface, shape: BoxShape.circle,
                  border: Border.all(color: DeskColors.line, width: 1.2)),
                child: Icon(Icons.arrow_forward_rounded, color: DeskColors.muted, size: 20.r))),
            SizedBox(width: 14.w),
            Expanded(child: Text('طلب الالتحاق', style: DeskText.heading(18.sp))),
            const DeskStatusChip(label: 'جديد', color: DeskColors.accent),
          ])),
        SizedBox(height: 18.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(children: [
            StepItem(label: 'بيانات المعلم', isActive: currentStep >= 0, isCompleted: currentStep > 0),
            StepConnector(isActive: currentStep >= 1),
            StepItem(label: 'التخصص', isActive: currentStep >= 1, isCompleted: currentStep > 1),
            StepConnector(isActive: currentStep >= 2),
            StepItem(label: 'التدريس', isActive: currentStep >= 2, isCompleted: currentStep > 2),
            StepConnector(isActive: currentStep >= 3),
            StepItem(label: 'الباقة', isActive: currentStep >= 3, isCompleted: currentStep > 3),
            StepConnector(isActive: currentStep >= 4),
            StepItem(label: 'الدفع والتفعيل', isActive: currentStep >= 4, isCompleted: currentStep > 4),
          ])),
        SizedBox(height: 20.h),
      ],
    );
  }
}
