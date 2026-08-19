import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Overlay shown when the student has exhausted all allowed views for a lesson.
class ViewLockedOverlay extends StatelessWidget {
  const ViewLockedOverlay({
    super.key,
    required this.viewCount,
    required this.maxViews,
  });

  /// Number of views consumed so far.
  final int viewCount;

  /// Maximum allowed views for this lesson.
  final int maxViews;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: NotebookColors.marginRed.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.visibility_off_rounded,
              color: NotebookColors.marginRed,
              size: 24.r,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.l10n.viewsExhaustedOverlay,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            context.l10n.viewsCountMessage(viewCount, maxViews),
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: Colors.white.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
