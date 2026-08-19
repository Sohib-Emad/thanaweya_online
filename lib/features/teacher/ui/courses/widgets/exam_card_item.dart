import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';

/// Individual exam card showing title, status, duration, and actions.
class ExamCardItem extends StatelessWidget {
  final ExamModel exam;

  const ExamCardItem({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(exam.title, style: DeskText.strong(13.5.sp))),
              DeskStatusChip(
                label: exam.isPublished ? 'منشور' : 'مسودة',
                color: exam.isPublished ? DeskColors.primary : DeskColors.accent,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'المدة: ${exam.durationMinutes} دقيقة • البداية: ${Formatters.formatDateTime(exam.startAt)}',
            style: DeskText.note(11.sp),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.teacherAddQuestion, arguments: exam.id),
                style: TextButton.styleFrom(foregroundColor: DeskColors.primary, minimumSize: Size.zero, padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)),
                icon: const Icon(Icons.list_alt_rounded, size: 16),
                label: Text('الأسئلة', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 8.w),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.teacherExamResults, arguments: {'examId': exam.id, 'examTitle': exam.title}),
                style: TextButton.styleFrom(foregroundColor: DeskColors.info, minimumSize: Size.zero, padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)),
                icon: const Icon(Icons.bar_chart_rounded, size: 16),
                label: Text('النتائج', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
