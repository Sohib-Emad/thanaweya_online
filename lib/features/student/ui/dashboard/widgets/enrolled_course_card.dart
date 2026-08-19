import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'cover_placeholder.dart';

/// A single enrolled course card showing cover, title, teacher, and progress bar.
class EnrolledCourseCard extends StatelessWidget {
  /// Creates an [EnrolledCourseCard].
  const EnrolledCourseCard({
    super.key,
    required this.title,
    required this.teacher,
    required this.subject,
    required this.coverUrl,
    required this.color,
    required this.progress,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final String title;
  final String teacher;
  final String subject;
  final String coverUrl;
  final Color color;
  final double progress;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 70,
      onTap: onTap,
      child: SizedBox(
        width: 220.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => CoverPlaceholder(color: color),
                          errorWidget: (_, _, _) => CoverPlaceholder(color: color),
                        )
                      : CoverPlaceholder(color: color),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subject.isNotEmpty)
                        Text(subject, style: GoogleFonts.cairo(fontSize: 9.5.sp, fontWeight: FontWeight.w800, color: NotebookColors.green)),
                      Text(title, style: NotebookText.heading(12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('أ. $teacher', style: NotebookText.note(9.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 5.h,
                      backgroundColor: NotebookColors.ink.withAlpha(20),
                      valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? NotebookColors.green : color),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  progress >= 1.0 ? 'مكتمل 100%' : '${(progress * 100).toInt()}%',
                  style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: progress >= 1.0 ? NotebookColors.green : color),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text('$done من $total دروس مكتملة', style: NotebookText.note(9.5.sp)),
          ],
        ),
      ),
    );
  }
}
