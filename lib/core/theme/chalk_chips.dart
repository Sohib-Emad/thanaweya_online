import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chalk_colors.dart';

/// A selectable chalk chip (selected fills with mint chalk).
class ChalkChip extends StatelessWidget {
  const ChalkChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent = ChalkboardColors.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? accent : ChalkboardColors.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? accent : ChalkboardColors.ink.withAlpha(60),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              color: selected
                  ? ChalkboardColors.onAccent
                  : ChalkboardColors.chalkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// A colored chalk status dot + label.
class ChalkStatusChip extends StatelessWidget {
  const ChalkStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withAlpha(110), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.r, color: color),
            SizedBox(width: 4.w),
          ] else ...[
            Container(
              width: 7.r,
              height: 7.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A rubber chalk stamp.
class ChalkStamp extends StatelessWidget {
  const ChalkStamp({
    super.key,
    required this.label,
    this.color = ChalkboardColors.accent,
    this.angle = -0.05,
  });

  final String label;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.6),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
