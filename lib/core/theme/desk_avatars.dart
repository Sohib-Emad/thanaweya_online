import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'desk_colors.dart';

/// A ringed avatar showing an initial.
class DeskAvatar extends StatelessWidget {
  const DeskAvatar({
    super.key,
    required this.initial,
    this.radius = 24,
    this.color = DeskColors.primary,
  });

  final String initial;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final name = initial.trim();
    final letter = name.isEmpty ? 'م' : name[0];
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.cairo(
            fontSize: radius * 0.85,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A comfortably-sized icon action (>= 40px tap target).
class DeskIconAction extends StatelessWidget {
  const DeskIconAction({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withAlpha(90), width: 1),
          ),
          child: Icon(icon, size: 19.r, color: color),
        ),
      ),
    );
  }
}

/// A labeled text action used in card footers.
class DeskLabeledAction extends StatelessWidget {
  const DeskLabeledAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.r, color: color),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
