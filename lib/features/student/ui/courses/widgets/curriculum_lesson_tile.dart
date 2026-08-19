import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A single lesson row inside the curriculum tab.
class CurriculumLessonTile extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final String courseId;
  final void Function(String lessonTitle)? onLocked;
  final VoidCallback? onComplete;

  const CurriculumLessonTile({
    super.key,
    required this.lesson,
    required this.courseId,
    this.onLocked,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final num = lesson['number'] as String;
    final title = lesson['title'] as String;
    final dur = lesson['duration'] as String;
    final unlocked = lesson['isUnlocked'] as bool;
    final isCompleted = lesson['isCompleted'] as bool? ?? false;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 64,
        marginTab: isCompleted,
        onTap: () {
          HapticFeedback.lightImpact();
          if (!unlocked) { onLocked?.call(title); return; }
          Navigator.pushNamed(context, AppRouter.studentVideoPlayer, arguments: {
            'lessonId': lesson['id'], 'videoUrl': lesson['videoUrl'],
            'title': title, 'courseId': courseId,
          }).then((_) => onComplete?.call());
        },
        child: Row(
          children: [
            Container(
              width: 34.r, height: 34.r,
              decoration: BoxDecoration(
                color: isCompleted ? NotebookColors.green.withAlpha(25) : NotebookColors.surfaceBright,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? NotebookColors.green
                      : (unlocked ? NotebookColors.green.withAlpha(90) : NotebookColors.ink.withAlpha(30)),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded, size: 18.r, color: NotebookColors.green)
                    : Text(num, style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w900,
                        color: unlocked ? NotebookColors.ink : NotebookColors.pencil)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(title, style: NotebookText.body(13.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (isCompleted) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: NotebookColors.green.withAlpha(22),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: NotebookColors.green.withAlpha(70)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle_rounded, size: 10.r, color: NotebookColors.green),
                        SizedBox(width: 2.w),
                        Text('مكتمل', style: GoogleFonts.cairo(fontSize: 9.sp, fontWeight: FontWeight.w800, color: NotebookColors.green)),
                      ]),
                    ),
                  ],
                ]),
                SizedBox(height: 2.h),
                Text(
                  unlocked ? (dur.isNotEmpty ? dur : l10n.lessonAvailable)
                      : (dur.isNotEmpty ? l10n.lessonDurationLocked(dur) : l10n.requiresSubscription),
                  style: NotebookText.note(10.sp, color: unlocked ? NotebookColors.pencil : NotebookColors.marginRed),
                ),
              ],
            )),
            Container(
              width: 30.r, height: 30.r,
              decoration: BoxDecoration(
                color: isCompleted || unlocked ? NotebookColors.green : NotebookColors.marginRed.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : (unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded),
                color: (isCompleted || unlocked) ? Colors.white : NotebookColors.marginRed,
                size: 16.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
