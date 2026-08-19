import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notebook_colors.dart';

/// A highlighter filter chip (selected fills with brand mint).
class NotebookChip extends StatelessWidget {
  const NotebookChip({
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
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: selected
              ? NotebookColors.green
              : NotebookColors.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? NotebookColors.green : NotebookColors.ink.withAlpha(40),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: selected ? NotebookColors.onGreen : NotebookColors.pencil,
            ),
          ),
        ),
      ),
    );
  }
}

/// A yellow-highlighted study note (for filter banners, tips, alerts).
class NotebookHighlightNote extends StatelessWidget {
  const NotebookHighlightNote({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(24, 8, 24, 0),
  });

  final Widget child;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: NotebookColors.highlighter,
        child: child,
      ),
    );
  }
}

/// A red rotated stamp badge.
class NotebookStamp extends StatelessWidget {
  const NotebookStamp({
    super.key,
    required this.label,
    this.angle = -0.06,
    this.color = NotebookColors.marginRed,
  });

  final String label;
  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}
