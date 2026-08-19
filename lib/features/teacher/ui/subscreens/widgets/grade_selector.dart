import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Horizontal grade selector chip row for attendance filtering.
class GradeSelector extends StatelessWidget {
  const GradeSelector({
    super.key,
    required this.selectedGrade,
    required this.onGradeChanged,
  });

  final String selectedGrade;
  final ValueChanged<String> onGradeChanged;

  static const _grades = [
    'الصف الثالث الثانوي',
    'الصف الثاني الثانوي',
    'الصف الأول الثانوي',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _grades.length,
        itemBuilder: (context, index) {
          final isSelected = selectedGrade == _grades[index];
          return DeskChip(
            label: _grades[index],
            selected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              onGradeChanged(_grades[index]);
            },
          );
        },
      ),
    );
  }
}
