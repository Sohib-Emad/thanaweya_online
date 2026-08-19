import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Row of selectable pills for choosing the correct answer index.
///
/// Shows either true/false labels or A/B/C/D letter pills depending
/// on the question [type].
class CorrectAnswerSelector extends StatelessWidget {
  const CorrectAnswerSelector({
    super.key,
    required this.type,
    required this.currentIndex,
    required this.onChanged,
  });

  final String type;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإجابة الصحيحة:', style: DeskText.strong(12.sp)),
        SizedBox(height: 6.h),
        if (type == 'true_false')
          Row(
            children: [
              _ChoicePill(label: 'صواب (صح)', index: 0,
                  currentIndex: currentIndex, onTap: onChanged),
              SizedBox(width: 8.w),
              _ChoicePill(label: 'خطأ (غير صحيح)', index: 1,
                  currentIndex: currentIndex, onTap: onChanged),
            ],
          )
        else
          Row(
            children: [
              _ChoicePill(label: 'أ', index: 0,
                  currentIndex: currentIndex, onTap: onChanged),
              SizedBox(width: 6.w),
              _ChoicePill(label: 'ب', index: 1,
                  currentIndex: currentIndex, onTap: onChanged),
              SizedBox(width: 6.w),
              _ChoicePill(label: 'ج', index: 2,
                  currentIndex: currentIndex, onTap: onChanged),
              SizedBox(width: 6.w),
              _ChoicePill(label: 'د', index: 3,
                  currentIndex: currentIndex, onTap: onChanged),
            ],
          ),
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? DeskColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
              color: isSelected ? DeskColors.primary : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
