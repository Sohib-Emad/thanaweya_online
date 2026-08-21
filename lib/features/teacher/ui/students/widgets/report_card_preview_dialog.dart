import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_helpers.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/report_metric_tile.dart';

/// Dialog that shows a certificate-style preview of the student report card with PDF printing.
class ReportCardPreviewDialog extends StatelessWidget {
  const ReportCardPreviewDialog({
    super.key,
    required this.studentName,
    required this.gradeLevel,
    required this.grades,
    required this.progress,
    this.courses = const [],
    required this.notesText,
  });

  final String studentName;
  final String gradeLevel;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> progress;
  final List<Map<String, dynamic>> courses;
  final String notesText;

  static Future<void> show(
    BuildContext context, {
    required String studentName,
    required String gradeLevel,
    required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> progress,
    List<Map<String, dynamic>> courses = const [],
    required String notesText,
  }) {
    HapticFeedback.lightImpact();
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (_) => ReportCardPreviewDialog(
        studentName: studentName,
        gradeLevel: gradeLevel,
        grades: grades,
        progress: progress,
        courses: courses,
        notesText: notesText,
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    HapticFeedback.mediumImpact();
    try {
      final doc = pw.Document(title: 'تقرير_أداء_$studentName');
      final fontRegular = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();

      final examAvg = ReportHelpers.calculateExamAverage(grades);
      final lessonRate = ReportHelpers.calculateLessonCompletionRate(progress);
      final gradeRating = ReportHelpers.calculateOverallGradeText(
        examAvg, lessonRate, grades, progress,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue800,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'منصة ثانوية أونلاين التعليمية',
                        style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.white),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'تقرير أداء ومتابعة الطالب الشامل لولي الأمر',
                        style: pw.TextStyle(font: fontRegular, fontSize: 12, color: PdfColors.blue100),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),

                // Student Info Row
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('اسم الطالب: $studentName', style: pw.TextStyle(font: fontBold, fontSize: 13)),
                          if (gradeLevel.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text('الصف الدراسي: $gradeLevel', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.amber100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          border: pw.Border.all(color: PdfColors.amber800),
                        ),
                        child: pw.Text('التقدير العام: $gradeRating', style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.amber900)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),

                // Performance Summary 3 boxes
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                        child: pw.Column(
                          children: [
                            pw.Text('الكورسات المسجلة', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                            pw.SizedBox(height: 2),
                            pw.Text('${courses.isNotEmpty ? courses.length : 1} كورس', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.blue800)),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                        child: pw.Column(
                          children: [
                            pw.Text('متوسط الامتحانات', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                            pw.SizedBox(height: 2),
                            pw.Text('${examAvg.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.purple800)),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                        child: pw.Column(
                          children: [
                            pw.Text('نسبة حضور الدروس', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                            pw.SizedBox(height: 2),
                            pw.Text('${lessonRate.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.green800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Exam Grades Table
                if (grades.isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  pw.Text('سجل درجات الامتحانات:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('اسم الامتحان', style: pw.TextStyle(font: fontBold, fontSize: 9))),
                          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('الدرجة', style: pw.TextStyle(font: fontBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('النسبة', style: pw.TextStyle(font: fontBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                        ],
                      ),
                      ...grades.map((g) {
                        final title = (g['exams'] as Map?)?['title'] as String? ?? 'اختبار';
                        final score = (g['score'] as num?)?.toInt() ?? 0;
                        final total = (g['total_points'] as num?)?.toInt() ?? 100;
                        final pct = total > 0 ? ((score / total) * 100).round() : 0;
                        return pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(title, style: pw.TextStyle(font: fontRegular, fontSize: 9))),
                            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('$score / $total', style: pw.TextStyle(font: fontRegular, fontSize: 9), textAlign: pw.TextAlign.center)),
                            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('$pct%', style: pw.TextStyle(font: fontBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                          ],
                        );
                      }),
                    ],
                  ),
                ],

                if (notesText.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.blue200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ملاحظات وتوصيات المعلم:', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.blue900)),
                        pw.SizedBox(height: 2),
                        pw.Text(notesText.trim(), style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),
                // Footer
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('منصة ثانوية أونلاين - thanaweya-online.com', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600)),
                    pw.Text('تاريخ التقرير: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'تقرير_أداء_$studentName.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تصدير الـ PDF: $e', style: GoogleFonts.cairo()),
            backgroundColor: DeskColors.danger,
          ),
        );
      }
    }
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(18.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    gradient: DeskColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 32.r),
                    SizedBox(height: 4.h),
                    Text(
                      'بطاقة تقرير أداء ومتابعة الطالب',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'منصة ثانوية أونلاين التعليمية',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ]),
                ),
                SizedBox(height: 14.h),

                Row(children: [
                  DeskAvatar(initial: studentName, radius: 22),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentName, style: DeskText.strong(15.sp)),
                        Text(
                          gradeLevel.isNotEmpty ? gradeLevel : 'المرحلة الثانوية',
                          style: DeskText.note(11.5.sp),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: rc.withAlpha(24),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: rc, width: 1),
                    ),
                    child: Text(
                      gradeRating,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w900,
                        color: rc,
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 14.h),

                Row(children: [
                  Expanded(
                    child: ReportMetricTile(
                      title: 'معدل الامتحانات',
                      value: '${examAvg.toStringAsFixed(1)}%',
                      icon: Icons.grade_rounded,
                      color: DeskColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ReportMetricTile(
                      title: 'حضور الدروس',
                      value: '${lessonRate.toStringAsFixed(1)}%',
                      icon: Icons.play_circle_fill_rounded,
                      color: DeskColors.info,
                    ),
                  ),
                ]),

                // Exams List Preview
                if (grades.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Text('سجل درجات الامتحانات:', style: DeskText.strong(12.sp)),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: DeskColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: DeskColors.line),
                    ),
                    child: Column(
                      children: grades.map((g) {
                        final title = (g['exams'] as Map?)?['title'] as String? ?? 'اختبار';
                        final score = (g['score'] as num?)?.toInt() ?? 0;
                        final total = (g['total_points'] as num?)?.toInt() ?? 100;
                        final pct = total > 0 ? ((score / total) * 100).round() : 0;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Row(
                            children: [
                              Expanded(child: Text(title, style: DeskText.body(11.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Text('$score / $total ($pct%)', style: DeskText.strong(11.5.sp)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                if (notesText.trim().isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: DeskColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: DeskColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.rate_review_rounded, size: 15.r, color: DeskColors.primary),
                          SizedBox(width: 6.w),
                          Text('ملاحظات وتوصيات المعلم:', style: DeskText.strong(11.5.sp)),
                        ]),
                        SizedBox(height: 4.h),
                        Text(notesText.trim(), style: DeskText.body(11.5.sp)),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16.h),

                // Action Buttons (Print PDF & Close)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => _exportPdf(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                        label: Text(
                          'طباعة كـ PDF',
                          style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'إغلاق',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
