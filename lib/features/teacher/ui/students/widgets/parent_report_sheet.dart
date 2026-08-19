import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_action_bar.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_card_preview_dialog.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_helpers.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_notes_section.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_sheet_header.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_sharing_actions.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_stats_summary.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_student_overview_card.dart';

/// Bottom sheet for generating and sharing a parent performance report.
class ParentReportSheet extends StatefulWidget {
  const ParentReportSheet({
    super.key,
    required this.studentName,
    required this.gradeLevel,
    required this.parentPhone,
    required this.grades,
    required this.progress,
    required this.subscriptions,
  });

  final String studentName;
  final String gradeLevel;
  final String parentPhone;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> progress;
  final List<Map<String, dynamic>> subscriptions;

  static Future<void> show(BuildContext context, {
    required String studentName, required String gradeLevel,
    required String parentPhone, required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> progress,
    required List<Map<String, dynamic>> subscriptions,
  }) {
    return showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ParentReportSheet(
        studentName: studentName, gradeLevel: gradeLevel,
        parentPhone: parentPhone, grades: grades,
        progress: progress, subscriptions: subscriptions,
      ),
    );
  }

  @override
  State<ParentReportSheet> createState() => _ParentReportSheetState();
}

class _ParentReportSheetState extends State<ParentReportSheet> {
  final _notesController = TextEditingController();

  @override
  void dispose() { _notesController.dispose(); super.dispose(); }

  String _reportText() => ReportHelpers.buildFormattedReportText(
    studentName: widget.studentName, gradeLevel: widget.gradeLevel,
    grades: widget.grades, progress: widget.progress,
    customNotes: _notesController.text.trim(),
  );

  void _copy() => ReportSharingActions.copyToClipboard(
    text: _reportText(), context: context,
  );

  void _whatsapp() => ReportSharingActions.shareViaWhatsApp(
    phone: widget.parentPhone, reportText: _reportText(),
    onFallbackCopy: _copy,
  );

  @override
  Widget build(BuildContext context) {
    final examAvg = ReportHelpers.calculateExamAverage(widget.grades);
    final lessonRate = ReportHelpers.calculateLessonCompletionRate(widget.progress);
    final overallRating = ReportHelpers.calculateOverallGradeText(
      examAvg, lessonRate, widget.grades, widget.progress,
    );
    final ratingColor = ReportHelpers.overallGradeColor(overallRating);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20.h),
        decoration: BoxDecoration(
          color: DeskColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 44.w, height: 5.h,
                decoration: BoxDecoration(color: DeskColors.line, borderRadius: BorderRadius.circular(10.r)),
              )),
              SizedBox(height: 16.h),
              const ReportSheetHeader(),
              SizedBox(height: 18.h),
              ReportStudentOverviewCard(
                studentName: widget.studentName, parentPhone: widget.parentPhone,
                ratingColor: ratingColor, overallRating: overallRating,
              ),
              SizedBox(height: 16.h),
              ReportStatsSummary(examAvg: examAvg, lessonRate: lessonRate),
              SizedBox(height: 16.h),
              ReportNotesSection(
                controller: _notesController,
                onPresetSelected: (preset) => setState(() {
                  final cur = _notesController.text.trim();
                  _notesController.text = cur.isEmpty ? preset : '$cur. $preset';
                }),
              ),
              SizedBox(height: 20.h),
              ReportActionBar(
                onWhatsApp: _whatsapp,
                onPreview: () => ReportCardPreviewDialog.show(
                  context, studentName: widget.studentName,
                  gradeLevel: widget.gradeLevel, grades: widget.grades,
                  progress: widget.progress, notesText: _notesController.text,
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
