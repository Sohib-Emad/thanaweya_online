import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Card widget displaying an exam's summary, attempts, and action buttons.
class ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback onTap;
  final VoidCallback onResults;
  const ExamCard({super.key, required this.exam, required this.onTap, required this.onResults});

  @override
  Widget build(BuildContext context) {
    final title = exam['title'] as String? ?? '';
    final duration = exam['duration_minutes'] as int? ?? 0;
    final subject = (exam['subject_name'] as String?) ?? '';
    final teacherName = (exam['teacher_name'] as String?) ?? '';
    final used = exam['attempts_used'] as int? ?? 0;
    final maxAttempts = exam['max_attempts'] as int? ?? 3;
    final locked = used >= maxAttempts;
    final remaining = (maxAttempts - used).clamp(0, maxAttempts);
    final qRaw = exam['questions'];
    final qCount = (qRaw is List && qRaw.isNotEmpty) ? (qRaw.first['count'] as int? ?? 0) : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: NotebookCard(
        ruled: true, ruledStartY: 92, marginTab: locked, onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (subject.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(6.r)),
                child: Text(subject, style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            if (teacherName.isNotEmpty && teacherName != subject) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: const Color(0xFF059669).withAlpha(18), borderRadius: BorderRadius.circular(6.r)),
                child: Text('أ/ $teacherName', style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFF059669))),
              ),
            ],
            const Spacer(),
            Icon(locked ? Icons.lock_rounded : Icons.quiz_rounded,
                color: locked ? NotebookColors.marginRed : const Color(0xFF0284C7), size: 20.r),
          ]),
          SizedBox(height: 8.h),
          Text(title, style: NotebookText.heading(14.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Row(children: [
            Icon(Icons.timer_outlined, size: 13.r, color: NotebookColors.pencil),
            SizedBox(width: 4.w),
            Text(context.l10n.examDurationLabel(duration), style: NotebookText.note(11.sp)),
            if (qCount > 0) ...[
              SizedBox(width: 10.w),
              Icon(Icons.help_outline_rounded, size: 13.r, color: NotebookColors.pencil),
              SizedBox(width: 4.w),
              Text('$qCount سؤال', style: NotebookText.note(11.sp)),
            ],
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(20),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, size: 12.r, color: const Color(0xFFD97706)),
                  SizedBox(width: 2.w),
                  Text(
                    '+20 نقطة',
                    style: GoogleFonts.cairo(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          SizedBox(height: 14.h),
          Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w, runSpacing: 8.h, children: [
            _chip(context, locked ? Icons.lock_rounded : Icons.repeat_rounded,
                locked ? NotebookColors.marginRed : NotebookColors.pencil,
                locked ? context.l10n.attemptsExhausted : context.l10n.attemptsCount(used, maxAttempts),
                locked ? NotebookColors.marginRed.withAlpha(16) : NotebookColors.surfaceBright,
                locked ? NotebookColors.marginRed.withAlpha(110) : NotebookColors.ink.withAlpha(35)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); onResults(); },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(color: NotebookColors.surfaceBright,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: NotebookColors.green.withAlpha(110), width: 1.2)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.insights_rounded, color: NotebookColors.green, size: 13.r),
                    SizedBox(width: 4.w),
                    Text(context.l10n.resultsLabel, style: NotebookText.strong(11.sp, color: NotebookColors.green)),
                  ]),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                    color: locked ? NotebookColors.marginRed.withAlpha(20) : NotebookColors.green,
                    borderRadius: BorderRadius.circular(20.r)),
                child: Row(children: [
                  Text(locked ? context.l10n.lockedLabel
                      : (remaining == maxAttempts ? context.l10n.enterExam : context.l10n.anotherAttempt),
                      style: NotebookText.strong(11.sp, color: locked ? NotebookColors.marginRed : Colors.white)),
                  SizedBox(width: 4.w),
                  Icon(locked ? Icons.lock_rounded : Icons.arrow_forward_rounded,
                      color: locked ? NotebookColors.marginRed : Colors.white, size: 12.r),
                ]),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(BuildContext ctx, IconData icon, Color iconColor, String text, Color bgColor, Color borderColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13.r, color: iconColor),
        SizedBox(width: 4.w),
        Text(text, style: NotebookText.strong(10.5.sp, color: iconColor)),
      ]),
    );
  }
}
