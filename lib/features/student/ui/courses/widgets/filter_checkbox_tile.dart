import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Custom checkbox tile used in filter screens.
class FilterCheckboxTile extends StatelessWidget {
  const FilterCheckboxTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  /// Display label.
  final String label;

  /// Whether the checkbox is checked.
  final bool isSelected;

  /// Callback toggled when the tile is tapped.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!isSelected);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isSelected ? NotebookColors.green : NotebookColors.surfaceBright,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected ? NotebookColors.green : NotebookColors.ink.withAlpha(50),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13.5.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? NotebookColors.ink : NotebookColors.pencil,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.push_pin_rounded,
                color: NotebookColors.marginRed.withAlpha(160),
                size: 15.r,
              ),
          ],
        ),
      ),
    );
  }
}
