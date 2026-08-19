import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/teacher/ui/students/widgets/parent_report_sheet.dart';

/// Bottom sheet for selecting a student to generate a parent report.
class StudentReportPickerSheet extends StatelessWidget {
  const StudentReportPickerSheet({
    super.key,
    required this.recentStudents,
  });

  final List<Map<String, dynamic>> recentStudents;

  /// Shows the student report picker sheet, or a snackbar if no students exist.
  static void show(
    BuildContext context, {
    required List<Map<String, dynamic>> recentStudents,
  }) {
    if (recentStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد طلاب مسجلين بعد لإنشاء تقرير',
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentReportPickerSheet(recentStudents: recentStudents),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'اختر الطالب لإصدار تقرير ولي الأمر',
              style: GoogleFonts.cairo(
                  fontSize: 15.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentStudents.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = recentStudents[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE0F2FE),
                    child: Text(
                      s['name']?[0] ?? 'ط',
                      style:
                          const TextStyle(color: Color(0xFF0284C7)),
                    ),
                  ),
                  title: Text(
                    s['name'] ?? '',
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    s['grade'] ?? '',
                    style: GoogleFonts.cairo(fontSize: 11.sp),
                  ),
                  trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () {
                    Navigator.pop(context);
                    ParentReportSheet.show(
                      context,
                      studentName: s['name'] ?? '',
                      gradeLevel: s['grade'] ?? '',
                      parentPhone: s['parentPhone'] ?? '',
                      grades: const [],
                      progress: const [],
                      subscriptions: const [],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
