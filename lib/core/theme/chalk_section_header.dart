import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chalk_colors.dart';
import 'chalk_text.dart';

/// A chalk section heading: colored chalk bar + title + optional action.
class ChalkSectionHeader extends StatelessWidget {
  const ChalkSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.accent = ChalkboardColors.accent,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 5.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(title, style: ChalkboardText.heading(16.sp)),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: accent,
              ),
              child: Row(
                children: [
                  Text(
                    actionLabel ?? 'الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, color: accent, size: 16.r),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
