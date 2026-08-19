import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Student overview card showing name, parent phone, and overall rating badge.
class ReportStudentOverviewCard extends StatelessWidget {
  const ReportStudentOverviewCard({
    super.key,
    required this.studentName,
    required this.parentPhone,
    required this.ratingColor,
    required this.overallRating,
  });

  final String studentName;
  final String parentPhone;
  final Color ratingColor;
  final String overallRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: DeskColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Row(
        children: [
          DeskAvatar(initial: studentName, radius: 24),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: DeskText.strong(15.sp)),
                SizedBox(height: 2.h),
                Text(
                  parentPhone.isNotEmpty
                      ? 'رقم ولي الأمر: $parentPhone'
                      : 'لم يتم تسجيل رقم ولي الأمر',
                  style: DeskText.note(11.5.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: ratingColor.withAlpha(20),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: ratingColor, width: 1),
            ),
            child: Text(
              overallRating,
              style: GoogleFonts.cairo(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                color: ratingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
