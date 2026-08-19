import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/desk_dropdown.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/field_label.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/teaching_mode_option.dart';

/// Step 2: location, teaching mode, and terms confirmation.
class TeacherFormStep2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? selectedGovernorate;
  final ValueChanged<String?> onGovernorateChanged;
  final String teachingMode;
  final ValueChanged<String> onTeachingModeChanged;
  final List<String> governorates;
  final bool agreedToTerms;
  final VoidCallback onAgreedToTermsToggled;

  const TeacherFormStep2({
    super.key,
    required this.formKey,
    required this.selectedGovernorate,
    required this.onGovernorateChanged,
    required this.teachingMode,
    required this.onTeachingModeChanged,
    required this.governorates,
    required this.agreedToTerms,
    required this.onAgreedToTermsToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey(2),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DeskSectionHeader(title: 'المراحل والتواصل'),
          SizedBox(height: 18.h),
          const FieldLabel(label: 'المحافظة الحالية*'),
          SizedBox(height: 8.h),
          DeskDropdown(
            label: 'المحافظة',
            value: selectedGovernorate,
            hint: 'اختر المحافظة...',
            options: governorates,
            onChanged: onGovernorateChanged,
          ),
          SizedBox(height: 20.h),
          const FieldLabel(label: 'طريقة التدريس المتاحة لديك*'),
          SizedBox(height: 10.h),
          Row(
            children: [
              TeachingModeOption(
                modeKey: 'online',
                label: 'أونلاين',
                iconData: Icons.laptop_mac_rounded,
                isSelected: teachingMode == 'online',
                onTap: onTeachingModeChanged,
              ),
              SizedBox(width: 8.w),
              TeachingModeOption(
                modeKey: 'center',
                label: 'سنتر',
                iconData: Icons.location_city_rounded,
                isSelected: teachingMode == 'center',
                onTap: onTeachingModeChanged,
              ),
              SizedBox(width: 8.w),
              TeachingModeOption(
                modeKey: 'both',
                label: 'كلاهما',
                iconData: Icons.auto_awesome_rounded,
                isSelected: teachingMode == 'both',
                onTap: onTeachingModeChanged,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: onAgreedToTermsToggled,
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: DeskColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: agreedToTerms
                      ? DeskColors.primary.withAlpha(140)
                      : DeskColors.line,
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: agreedToTerms
                          ? DeskColors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: agreedToTerms
                            ? DeskColors.primary
                            : DeskColors.faint,
                        width: 1.6,
                      ),
                    ),
                    child: agreedToTerms
                        ? Icon(
                            Icons.check_rounded,
                            color: DeskColors.onPrimary,
                            size: 16.r,
                          )
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'أقر أنا المعلم بصحة البيانات المدخلة وبالموافقة على شروط وقوانين منصة ثانوية أونلاين.',
                      style: DeskText.body(12.sp, color: DeskColors.muted)
                          .copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
