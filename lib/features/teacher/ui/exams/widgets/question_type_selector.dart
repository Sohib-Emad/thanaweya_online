import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Row of selectable question type chips (MCQ, true/false, essay).
///
/// Used inside the [AddQuestionSheet] to pick the question format.
class QuestionTypeSelector extends StatelessWidget {
  const QuestionTypeSelector({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  final String currentType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نوع السؤال:', style: DeskText.strong(12.sp)),
        SizedBox(height: 6.h),
        Row(
          children: [
            _TypeChip(label: 'اختيار من متعدد', value: 'mcq',
                isSelected: currentType == 'mcq', onTap: onTypeChanged),
            SizedBox(width: 6.w),
            _TypeChip(label: 'صح أو خطأ', value: 'true_false',
                isSelected: currentType == 'true_false', onTap: onTypeChanged),
            SizedBox(width: 6.w),
            _TypeChip(label: 'سؤال مقالي', value: 'essay',
                isSelected: currentType == 'essay', onTap: onTypeChanged),
          ],
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? DeskColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                color: isSelected ? DeskColors.primary : const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
