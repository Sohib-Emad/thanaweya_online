import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notebook_colors.dart';
import 'notebook_text.dart';

/// A notebook section heading: red margin tab + title + optional action.
class NotebookSectionHeader extends StatelessWidget {
  const NotebookSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Container(
            width: 5.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: NotebookColors.marginRed,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(title, style: NotebookText.heading(16.sp)),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    actionLabel ?? 'الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: NotebookColors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, color: NotebookColors.green, size: 16.r),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A subject margin tab (selected shows as an inked index tab).
class NotebookMarginTab extends StatelessWidget {
  const NotebookMarginTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? NotebookColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: selected
                ? NotebookColors.marginRed.withAlpha(180)
                : NotebookColors.ink.withAlpha(50),
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: NotebookColors.ink.withAlpha(12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              color: selected ? NotebookColors.ink : NotebookColors.pencil,
            ),
          ),
        ),
      ),
    );
  }
}
