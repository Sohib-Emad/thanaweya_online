import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_action_bar.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_card_preview_dialog.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_helpers.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_notes_section.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_sheet_header.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_sharing_actions.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_stats_summary.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_student_overview_card.dart';

/// Comprehensive bottom sheet for generating and sharing a detailed parent performance report.
class ParentReportSheet extends StatefulWidget {
  const ParentReportSheet({
    super.key,
    required this.studentName,
    required this.gradeLevel,
    required this.parentPhone,
    required this.grades,
    required this.progress,
    required this.subscriptions,
    this.courses = const [],
  });

  final String studentName;
  final String gradeLevel;
  final String parentPhone;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> progress;
  final List<Map<String, dynamic>> subscriptions;
  final List<Map<String, dynamic>> courses;

  static Future<void> show(
    BuildContext context, {
    required String studentName,
    required String gradeLevel,
    required String parentPhone,
    required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> progress,
    required List<Map<String, dynamic>> subscriptions,
    List<Map<String, dynamic>> courses = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ParentReportSheet(
        studentName: studentName,
        gradeLevel: gradeLevel,
        parentPhone: parentPhone,
        grades: grades,
        progress: progress,
        subscriptions: subscriptions,
        courses: courses,
      ),
    );
  }

  @override
  State<ParentReportSheet> createState() => _ParentReportSheetState();
}

class _ParentReportSheetState extends State<ParentReportSheet> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _effectiveCourses {
    if (widget.courses.isNotEmpty) return widget.courses;
    final map = <String, Map<String, dynamic>>{};
    for (final p in widget.progress) {
      final cid = p['course_id'] as String? ?? '';
      final title = p['course_title'] as String? ?? '';
      if (cid.isNotEmpty || title.isNotEmpty) {
        map.putIfAbsent(cid.isNotEmpty ? cid : title, () => {'id': cid, 'title': title.isNotEmpty ? title : 'كورس تعليمي'});
      }
    }
    return map.values.toList();
  }

  String _reportText() => ReportHelpers.buildFormattedReportText(
        studentName: widget.studentName,
        gradeLevel: widget.gradeLevel,
        grades: widget.grades,
        progress: widget.progress,
        courses: _effectiveCourses,
        customNotes: _notesController.text.trim(),
      );

  void _copy() => ReportSharingActions.copyToClipboard(
        text: _reportText(),
        context: context,
      );

  void _whatsapp() => ReportSharingActions.shareViaWhatsApp(
        context: context,
        phone: widget.parentPhone,
        reportText: _reportText(),
        onFallbackCopy: _copy,
      );

  @override
  Widget build(BuildContext context) {
    final examAvg = ReportHelpers.calculateExamAverage(widget.grades);
    final lessonRate = ReportHelpers.calculateLessonCompletionRate(widget.progress);
    final overallRating = ReportHelpers.calculateOverallGradeText(
      examAvg,
      lessonRate,
      widget.grades,
      widget.progress,
    );
    final ratingColor = ReportHelpers.overallGradeColor(overallRating);
    final watchedMinutes = ReportHelpers.calculateTotalWatchedMinutes(widget.progress);
    final courses = _effectiveCourses;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: DeskColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: DeskColors.line,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              const ReportSheetHeader(),
              SizedBox(height: 16.h),

              // 1. Overview Card
              ReportStudentOverviewCard(
                studentName: widget.studentName,
                parentPhone: widget.parentPhone,
                ratingColor: ratingColor,
                overallRating: overallRating,
              ),
              SizedBox(height: 14.h),

              // 2. 4-Tile Quick Metrics
              ReportStatsSummary(
                examAvg: examAvg,
                lessonRate: lessonRate,
                coursesCount: courses.isNotEmpty ? courses.length : 1,
                totalWatchedMinutes: watchedMinutes,
                examsCount: widget.grades.length,
              ),
              SizedBox(height: 16.h),

              // 3. Enrolled Courses Section
              if (courses.isNotEmpty) ...[
                Text('الكورسات المسجل بها (${courses.length})', style: DeskText.strong(12.5.sp)),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: DeskColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: DeskColors.line),
                  ),
                  child: Column(
                    children: courses.map((c) {
                      final title = c['title'] as String? ?? 'كورس تعليمي';
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14.r, color: const Color(0xFF0284C7)),
                            SizedBox(width: 8.w),
                            Expanded(child: Text(title, style: DeskText.body(12.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // 4. Exams Breakdown Section
              Text('سجل درجات الامتحانات (${widget.grades.length})', style: DeskText.strong(12.5.sp)),
              SizedBox(height: 8.h),
              if (widget.grades.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: DeskColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: DeskColors.line),
                  ),
                  child: Center(
                    child: Text('لم يؤدِ الطالب أي امتحانات بعد', style: DeskText.note(11.5.sp)),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: DeskColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: DeskColors.line),
                  ),
                  child: Column(
                    children: widget.grades.map((g) {
                      final examTitle = (g['exams'] as Map?)?['title'] as String? ??
                          g['exam_title'] as String? ??
                          'اختبار';
                      final score = (g['score'] as num?)?.toInt() ?? 0;
                      final total = (g['total_points'] as num?)?.toInt() ??
                          ((g['exams'] as Map?)?['max_score'] as num?)?.toInt() ??
                          100;
                      final passingScore =
                          ((g['exams'] as Map?)?['passing_score'] as num?)?.toInt() ?? 50;
                      final pct = total > 0 ? ((score / total) * 100).round() : 0;
                      final passed = pct >= passingScore;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(examTitle, style: DeskText.strong(12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('$score / $total ($pct%)', style: DeskText.note(10.5.sp)),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: passed ? const Color(0xFF059669).withAlpha(18) : const Color(0xFFEF4444).withAlpha(18),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: passed ? const Color(0xFF059669) : const Color(0xFFEF4444)),
                              ),
                              child: Text(
                                passed ? 'ناجح ✅' : 'راسب ⚠️',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: passed ? const Color(0xFF059669) : const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 16.h),

              // 5. Notes & Recommendations
              ReportNotesSection(
                controller: _notesController,
                onPresetSelected: (preset) => setState(() {
                  final cur = _notesController.text.trim();
                  _notesController.text =
                      cur.isEmpty ? preset : '$cur. $preset';
                }),
              ),
              SizedBox(height: 20.h),

              // 6. Action Bar
              ReportActionBar(
                onWhatsApp: _whatsapp,
                onPreview: () => ReportCardPreviewDialog.show(
                  context,
                  studentName: widget.studentName,
                  gradeLevel: widget.gradeLevel,
                  grades: widget.grades,
                  progress: widget.progress,
                  courses: courses,
                  notesText: _notesController.text,
                ),
                onCopy: _copy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
