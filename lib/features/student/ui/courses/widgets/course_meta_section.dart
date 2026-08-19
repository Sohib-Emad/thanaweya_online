import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Subject badge, title, and stats row displayed below the cover.
class CourseMetaSection extends StatelessWidget {
  final Map<String, dynamic> course;
  final int lessonCount;
  final String totalDurationText;
  final String subjectName;

  const CourseMetaSection({
    super.key,
    required this.course,
    required this.lessonCount,
    required this.totalDurationText,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = (course['price'] as num?)?.toDouble();

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (subjectName.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: NotebookColors.green,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    subjectName,
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(width: 10.w),
              Text(
                course['stage'] as String? ?? '',
                style: NotebookText.note(11.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            course['title'] as String? ?? '',
            style: NotebookText.heading(19.sp),
          ),
          SizedBox(height: 10.h),
          _StatsRow(
            lessonCount: lessonCount,
            totalDurationText: totalDurationText,
            price: price,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int lessonCount;
  final String totalDurationText;
  final double? price;
  final AppLocalizations l10n;

  const _StatsRow({
    required this.lessonCount,
    required this.totalDurationText,
    required this.price,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.video_collection_outlined, size: 15.r, color: NotebookColors.pencil),
        SizedBox(width: 4.w),
        Text(l10n.lessonCount(lessonCount), style: NotebookText.body(12.sp)),
        if (totalDurationText.isNotEmpty) ...[
          SizedBox(width: 14.w),
          Container(width: 1, height: 14.h, color: NotebookColors.ink.withAlpha(40)),
          SizedBox(width: 14.w),
          Icon(Icons.access_time_rounded, size: 15.r, color: NotebookColors.pencil),
          SizedBox(width: 4.w),
          Text(totalDurationText, style: NotebookText.body(12.sp)),
        ],
        if (price != null) ...[
          SizedBox(width: 14.w),
          Container(width: 1, height: 14.h, color: NotebookColors.ink.withAlpha(40)),
          SizedBox(width: 14.w),
          Icon(Icons.payments_outlined, size: 15.r, color: NotebookColors.marginRed),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              Formatters.formatEgp(price!),
              style: NotebookText.strong(12.sp, color: NotebookColors.marginRed),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
