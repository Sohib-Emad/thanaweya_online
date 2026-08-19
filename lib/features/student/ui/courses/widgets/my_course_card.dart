import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'course_cover_placeholder.dart';

/// Card displaying a course with cover, progress, and action arrow.
class MyCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Color color;
  final int selectedTab;
  const MyCourseCard({super.key, required this.course, required this.color, required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    final double progress = (course['progress'] as double?) ?? 0.0;
    final int done = (course['completedCount'] as int?) ?? 0;
    final int total = (course['totalCount'] as int?) ?? _lessonCountOf(course['lessons']);
    final subject = (course['subject_name'] as String?) ?? (course['subject'] as String?) ?? '';
    final title = course['title'] as String? ?? '';
    final teacherName = course['teacher_name'] as String? ?? '';
    final coverUrl = course['cover_image_url'] as String? ?? '';
    final teacherLine = teacherName.startsWith('أ.') ? teacherName : 'أ. $teacherName';
    final isComplete = progress >= 1.0;
    final progressColor = isComplete ? NotebookColors.green : color;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: NotebookCard(
        ruled: true, ruledStartY: 118,
        onTap: () {
          HapticFeedback.lightImpact();
          if (selectedTab == 0) {
            Navigator.pushNamed(context, AppRouter.studentCertificate);
          } else {
            Navigator.pushNamed(context, AppRouter.studentCurriculum, arguments: course['id'] as String);
          }
        },
        child: Row(children: [
          Container(
            width: 72.r, height: 72.r, clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: color.withAlpha(18), borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: color.withAlpha(90), width: 1.2),
            ),
            child: coverUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: coverUrl, fit: BoxFit.cover,
                    placeholder: (_, _) => CourseCoverPlaceholder(color: color, subject: subject),
                    errorWidget: (_, _, _) => CourseCoverPlaceholder(color: color, subject: subject))
                : CourseCoverPlaceholder(color: color, subject: subject),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(teacherLine, style: NotebookText.note(10.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 2.h),
            Text(title, style: NotebookText.heading(13.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0), minHeight: 6.h,
                  backgroundColor: NotebookColors.ink.withAlpha(22),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              )),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(color: progressColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(4.r)),
                child: Text(
                    isComplete ? 'مكتمل 100%' : '$done/$total (${(progress * 100).toInt()}%)',
                    style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: progressColor)),
              ),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 13.r),
              SizedBox(width: 4.w),
              Text('${course['rating'] ?? '4.8'}', style: NotebookText.strong(11.sp)),
              SizedBox(width: 12.w),
              Icon(Icons.person_outline_rounded, color: NotebookColors.pencil, size: 13.r),
              SizedBox(width: 4.w),
              Expanded(child: Text(subject, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: NotebookText.note(10.sp))),
            ]),
          ])),
          SizedBox(width: 6.w),
          Container(
            width: 28.r, height: 28.r,
            decoration: BoxDecoration(color: NotebookColors.green, shape: BoxShape.circle),
            child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15.r),
          ),
        ]),
      ),
    );
  }

  int _lessonCountOf(dynamic lessons) {
    if (lessons is Map) return (lessons['count'] as int?) ?? 0;
    if (lessons is List && lessons.isNotEmpty) {
      final first = lessons.first;
      if (first is Map) return (first['count'] as int?) ?? 0;
    }
    return 0;
  }
}
