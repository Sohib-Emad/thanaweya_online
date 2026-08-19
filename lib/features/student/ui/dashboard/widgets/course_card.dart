import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'cover_placeholder.dart';

/// A ruled summary page card for a popular course.
class CourseCard extends StatelessWidget {
  /// Creates a [CourseCard].
  const CourseCard({
    super.key,
    required this.id,
    required this.title,
    required this.teacher,
    required this.subject,
    this.coverUrl,
    required this.color,
    this.price,
  });

  final String id;
  final String title;
  final String teacher;
  final String subject;
  final String? coverUrl;
  final Color color;
  final num? price;

  @override
  Widget build(BuildContext context) {
    final sanitizedSubject = subject.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '').trim();
    final teacherLine = teacher.startsWith('أ.') ? teacher : 'أ. $teacher';

    return NotebookCard(
      ruled: true,
      ruledStartY: 96,
      marginTab: true,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRouter.studentCourseDetails, arguments: id);
      },
      child: SizedBox(
        width: 180.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 92.h,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: NotebookColors.ink,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: (coverUrl?.isNotEmpty ?? false)
                  ? CachedNetworkImage(
                      imageUrl: coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => CoverPlaceholder(color: color),
                      errorWidget: (_, _, _) => CoverPlaceholder(color: color),
                    )
                  : CoverPlaceholder(color: color),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (sanitizedSubject.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: NotebookColors.green,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(sanitizedSubject, style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRouter.studentBookmarks),
                  child: Icon(Icons.bookmark_border_rounded, size: 16.r, color: NotebookColors.pencil),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(teacherLine, style: NotebookText.note(11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4.h),
            Text(title, style: NotebookText.heading(13.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 5.h),
            Container(width: 44.w, height: 3.h, color: color),
            const Spacer(),
            Row(
              children: [
                if (price != null)
                  Flexible(
                    child: Text(
                      Formatters.formatEgp(price!.toDouble()),
                      style: NotebookText.strong(11.sp, color: NotebookColors.marginRed),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Text(context.l10n.continueCourse, style: NotebookText.note(10.sp)),
                const Spacer(),
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(color: NotebookColors.green, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15.r),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
