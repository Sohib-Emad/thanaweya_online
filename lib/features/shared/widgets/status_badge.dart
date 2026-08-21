import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable status badge widget for showing active, pending, or custom states.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isSolid;

  const StatusBadge({
    super.key,
    required this.label,
    this.color = const Color(0xFF0284C7),
    this.icon,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withAlpha(20),
        borderRadius: BorderRadius.circular(6.r),
        border: isSolid ? null : Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.r, color: isSolid ? Colors.white : color),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: isSolid ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
