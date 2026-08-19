import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A compact stat display cell used inside cards to show a single
/// numeric value with an optional icon and label beneath it.
class StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData? icon;

  const StatCell({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.w),
        child: Column(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.r, color: accent),
              SizedBox(height: 4.h),
            ],
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
