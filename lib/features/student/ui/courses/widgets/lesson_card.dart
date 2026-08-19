import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Card representing a single lesson in the course lessons list.
class LessonCard extends StatelessWidget {
  final String title;
  final String? description;
  final String number;
  final bool isCompleted;
  final bool isSubscribed;
  final int? durationSeconds;
  final VoidCallback onTap;
  const LessonCard({
    super.key, required this.title, this.description, required this.number,
    required this.isCompleted, required this.isSubscribed, this.durationSeconds, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true, ruledStartY: 76, marginTab: isCompleted, onTap: onTap,
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isCompleted ? NotebookColors.green.withAlpha(25) : NotebookColors.surfaceBright,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isCompleted ? NotebookColors.green
                  : (!isSubscribed ? NotebookColors.marginRed : NotebookColors.ink.withAlpha(30)),
              width: 1.5),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded
                : (!isSubscribed ? Icons.lock_rounded : Icons.play_circle_outline_rounded),
            color: isCompleted ? NotebookColors.green
                : (!isSubscribed ? NotebookColors.marginRed : NotebookColors.ink),
            size: 22.r),
        ),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(color: NotebookColors.marginRed.withAlpha(22),
                  borderRadius: BorderRadius.circular(4.r)),
              child: Text('${context.l10n.lessonNumber}$number',
                  style: GoogleFonts.cairo(fontSize: 9.sp, fontWeight: FontWeight.w800,
                      color: NotebookColors.marginRed)),
            ),
            if (isCompleted) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(color: NotebookColors.green.withAlpha(22),
                    borderRadius: BorderRadius.circular(4.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_rounded, size: 10.r, color: NotebookColors.green),
                  SizedBox(width: 2.w),
                  Text('مكتمل', style: GoogleFonts.cairo(fontSize: 9.sp,
                      fontWeight: FontWeight.w800, color: NotebookColors.green)),
                ]),
              ),
            ],
            SizedBox(width: 8.w),
            Expanded(child: Text(title, style: NotebookText.body(13.sp),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          if ((description ?? '').isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(description!, style: NotebookText.note(10.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          if (durationSeconds != null) ...[
            SizedBox(height: 3.h),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 11.r, color: NotebookColors.pencil),
              SizedBox(width: 4.w),
              Text(Formatters.formatDurationMinutes((durationSeconds! / 60).ceil()),
                  style: NotebookText.note(10.sp)),
            ]),
          ],
        ])),
        Container(
          width: 30.r, height: 30.r,
          decoration: BoxDecoration(
            color: isCompleted ? NotebookColors.green : NotebookColors.ink.withAlpha(35),
            shape: BoxShape.circle),
          child: Icon(isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
              color: Colors.white, size: 17.r),
        ),
      ]),
    );
  }
}
