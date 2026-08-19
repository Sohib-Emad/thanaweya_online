import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Row of filter tabs for all / available / used cards.
class CardFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final int allCount;
  final int availableCount;
  final int usedCount;
  final ValueChanged<int> onSelected;

  const CardFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.allCount,
    required this.availableCount,
    required this.usedCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _FilterTab(
            index: 0,
            label: 'الكل ($allCount)',
            isSelected: selectedIndex == 0,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(0);
            },
          ),
          SizedBox(width: 8.w),
          _FilterTab(
            index: 1,
            label: 'المتاحة ($availableCount)',
            isSelected: selectedIndex == 1,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(1);
            },
          ),
          SizedBox(width: 8.w),
          _FilterTab(
            index: 2,
            label: 'المستعملة ($usedCount)',
            isSelected: selectedIndex == 2,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(2);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: isSelected ? DeskColors.primary : DeskColors.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? DeskColors.primary : DeskColors.line,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? DeskColors.onPrimary : DeskColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
