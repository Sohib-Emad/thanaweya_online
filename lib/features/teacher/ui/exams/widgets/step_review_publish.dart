import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Step 3 of the exam builder wizard: review summary before publishing.
///
/// Shows exam title, description, linked course, duration, question count,
/// and total score in a preview card with an info notice.
class StepReviewPublish extends StatelessWidget {
  const StepReviewPublish({
    super.key,
    required this.title,
    required this.description,
    required this.courseTitle,
    required this.duration,
    required this.questionCount,
    required this.totalScore,
  });

  final String title, description, courseTitle, duration;
  final int questionCount, totalScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الخطوة 3: معاينة الامتحان ونشره', style: DeskText.heading(15.sp)),
        SizedBox(height: 14.h),
        _SummaryCard(
          title: title,
          description: description,
          courseTitle: courseTitle,
          duration: duration,
          questionCount: questionCount,
          totalScore: totalScore,
        ),
        SizedBox(height: 16.h),
        const _PublishNotice(),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.description,
    required this.courseTitle,
    required this.duration,
    required this.questionCount,
    required this.totalScore,
  });

  final String title, description, courseTitle, duration;
  final int questionCount, totalScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DeskText.heading(16.sp)),
          if (description.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(description, style: DeskText.note(12.sp)),
            SizedBox(height: 10.h),
          ],
          const Divider(),
          _ReviewRow(icon: Icons.menu_book_outlined, label: 'الكورس المرتبط:', value: courseTitle),
          SizedBox(height: 8.h),
          _ReviewRow(icon: Icons.timer_outlined, label: 'المدة الزمنية:', value: '$duration دقيقة'),
          SizedBox(height: 8.h),
          _ReviewRow(icon: Icons.quiz_outlined, label: 'عدد الأسئلة:', value: '$questionCount سؤال'),
          SizedBox(height: 8.h),
          _ReviewRow(icon: Icons.grade_outlined, label: 'الدرجة الكلية:', value: '$totalScore درجة'),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: DeskColors.primary),
        SizedBox(width: 8.w),
        Text(label, style: DeskText.note(12.sp)),
        SizedBox(width: 6.w),
        Text(value, style: DeskText.strong(12.5.sp)),
      ],
    );
  }
}

class _PublishNotice extends StatelessWidget {
  const _PublishNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'سيصبح هذا الامتحان متاحاً فوراً لجميع الطلاب المشتركين في هذا الكورس.',
              style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0369A1)),
            ),
          ),
        ],
      ),
    );
  }
}
