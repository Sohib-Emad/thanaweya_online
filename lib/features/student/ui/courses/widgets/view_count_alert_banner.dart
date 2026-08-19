import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// An informational banner that shows how many views remain for a lesson and
/// warns the student when the limit is approaching or already exhausted.
class ViewCountAlertBanner extends StatelessWidget {
  const ViewCountAlertBanner({
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
    final remaining = (maxViews - viewCount).clamp(0, maxViews);
    final isExhausted = viewCount >= maxViews;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isExhausted
            ? const Color(0xFFEF4444).withAlpha(15)
            : const Color(0xFF0284C7).withAlpha(12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isExhausted
              ? const Color(0xFFEF4444).withAlpha(45)
              : const Color(0xFF0284C7).withAlpha(35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExhausted
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            color: isExhausted
                ? const Color(0xFFEF4444)
                : const Color(0xFF0284C7),
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isExhausted
                  ? '\u062a\u0646\u0628\u064a\u0647: \u0644\u0642\u062f \u0627\u0633\u062a\u0646\u0641\u062f\u062a \u062c\u0645\u064a\u0639 \u0645\u0631\u0627\u062a \u0645\u0634\u0627\u0647\u062f\u0629 \u0647\u0630\u0647 \u0627\u0644\u062d\u0635\u0629 ($maxViews \u0645\u0631\u0627\u062a). \u062a\u0648\u0627\u0635\u0644 \u0645\u0639 \u0627\u0644\u0645\u0639\u0644\u0645 \u0644\u0625\u0639\u0627\u062f\u0629 \u0641\u062a\u062d \u0627\u0644\u0645\u0634\u0627\u0647\u062f\u0627\u062a.'
                  : '\u062a\u0646\u0628\u064a\u0647: \u0627\u0644\u062d\u062f \u0627\u0644\u0623\u0642\u0635\u0649 \u0644\u0645\u0634\u0627\u0647\u062f\u0629 \u0647\u0630\u0647 \u0627\u0644\u062d\u0635\u0629 \u0647\u0648 $maxViews \u0645\u0631\u0627\u062a (\u0634\u0627\u0647\u062f\u062a $viewCount \u0645\u0646 $maxViews \u0645\u0631\u0627\u062a \u2022 \u0645\u062a\u0628\u0642\u064a $remaining \u0645\u0631\u0627\u062a).',
              style: GoogleFonts.cairo(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: isExhausted
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF0369A1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
