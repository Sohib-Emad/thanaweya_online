import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_helpers.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_metric_tile.dart';

/// Dialog that shows a certificate-style preview of the student report card.
class ReportCardPreviewDialog extends StatelessWidget {
  const ReportCardPreviewDialog({
    super.key,
    required this.studentName,
    required this.gradeLevel,
    required this.grades,
    required this.progress,
    required this.notesText,
  });

  final String studentName;
  final String gradeLevel;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> progress;
  final String notesText;

  static Future<void> show(BuildContext context, {
    required String studentName, required String gradeLevel,
    required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> progress,
    required String notesText,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ReportCardPreviewDialog(
        studentName: studentName, gradeLevel: gradeLevel,
        grades: grades, progress: progress, notesText: notesText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examAvg = ReportHelpers.calculateExamAverage(grades);
    final lessonRate = ReportHelpers.calculateLessonCompletionRate(progress);
    final gradeRating = ReportHelpers.calculateOverallGradeText(
      examAvg, lessonRate, grades, progress,
    );
    final rc = ReportHelpers.overallGradeColor(gradeRating);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    gradient: DeskColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 40.r),
                    SizedBox(height: 8.h),
                    Text('بطاقة تقرير أداء الطالب', style: GoogleFonts.cairo(
                      fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('منصة ثانوية أونلاين التعليمية', style: GoogleFonts.cairo(
                      fontSize: 12.sp, color: Colors.white.withAlpha(200))),
                  ]),
                ),
                SizedBox(height: 16.h),
                Row(children: [
                  DeskAvatar(initial: studentName, radius: 24),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName, style: DeskText.strong(16.sp)),
                      Text(gradeLevel.isNotEmpty ? gradeLevel : 'الصف الدراسي غير محدد', style: DeskText.note(12.sp)),
                    ],
                  )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: rc.withAlpha(24), borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: rc, width: 1),
                    ),
                    child: Text(gradeRating, style: GoogleFonts.cairo(
                      fontSize: 12.sp, fontWeight: FontWeight.w900, color: rc)),
                  ),
                ]),
                SizedBox(height: 20.h),
                Row(children: [
                  Expanded(child: ReportMetricTile(
                    title: 'معدل الامتحانات', value: '${examAvg.toStringAsFixed(1)}%',
                    icon: Icons.grade_rounded, color: DeskColors.primary)),
                  SizedBox(width: 10.w),
                  Expanded(child: ReportMetricTile(
                    title: 'حضور الدروس', value: '${lessonRate.toStringAsFixed(1)}%',
                    icon: Icons.play_circle_fill_rounded, color: DeskColors.info)),
                ]),
                if (notesText.trim().isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: DeskColors.surfaceAlt, borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: DeskColors.line),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.rate_review_rounded, size: 16.r, color: DeskColors.primary),
                        SizedBox(width: 6.w),
                        Text('ملاحظات وتوصيات المعلم:', style: DeskText.strong(12.sp)),
                      ]),
                      SizedBox(height: 6.h),
                      Text(notesText.trim(), style: DeskText.body(12.sp)),
                    ]),
                  ),
                ],
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeskColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('إغلاق المعاينة', style: GoogleFonts.cairo(
                    fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
