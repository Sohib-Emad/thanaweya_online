import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// The body of the analytics screen showing the date range filter.
class RangeFilter extends StatelessWidget {
  final int selectedIndex;
  final List<String> ranges;
  final ValueChanged<int> onSelected;

  const RangeFilter({
    super.key,
    required this.selectedIndex,
    required this.ranges,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ranges.asMap().entries.map((entry) {
          final isSelected = selectedIndex == entry.key;
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: ChoiceChip(
              label: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF475569),
                ),
              ),
              selected: isSelected,
              selectedColor: DeskColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                    color: isSelected
                        ? DeskColors.primary
                        : DeskColors.line),
              ),
              onSelected: (_) => onSelected(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
