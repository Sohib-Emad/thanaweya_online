import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/utils/lesson_progression_helper.dart';

/// Modal dialog shown when a student taps a locked lesson requiring
/// passing an exam or attending the previous lesson.
class LessonExamRequiredDialog extends StatelessWidget {
  final String lessonTitle;
  final LessonLockStatus lockStatus;
  final String courseId;
  final VoidCallback? onRefresh;

  const LessonExamRequiredDialog({
    super.key,
    required this.lessonTitle,
    required this.lockStatus,
    required this.courseId,
    this.onRefresh,
  });

  static Future<void> show(
    BuildContext context, {
    required String lessonTitle,
    required LessonLockStatus lockStatus,
    required String courseId,
    VoidCallback? onRefresh,
  }) {
    HapticFeedback.lightImpact();
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (_) => LessonExamRequiredDialog(
        lessonTitle: lessonTitle,
        lockStatus: lockStatus,
        courseId: courseId,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exam = lockStatus.requiredExam;
    final hasExam = exam != null;
    final examTitle = exam?['title'] as String? ?? 'امتحان الحصة السابقة';
    final passingScore = (exam?['passing_score'] as num?)?.toInt() ?? 50;
    final prevTitle = lockStatus.previousLessonTitle ?? 'الحصة السابقة';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  color: hasExam
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    hasExam ? Icons.quiz_rounded : Icons.lock_clock_rounded,
                    color: hasExam
                        ? const Color(0xFFD97706)
                        : const Color(0xFFDC2626),
                    size: 30.r,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Text(
                'هذه الحصة مغلقة حالياً',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8.h),

              Text(
                hasExam
                    ? 'لضمان استيعابك للمنهج، يشترط المعلم اجتياز امتحان ($prevTitle) أولاً لفتح ($lessonTitle).'
                    : 'يجب عليك استكمال مشاهدة ($prevTitle) أولاً لتتمكن من متابعة ($lessonTitle).',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),

              // Detail Card
              if (hasExam) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(20),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.assignment_outlined,
                            color: const Color(0xFF0284C7), size: 18.r),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(examTitle,
                                style: GoogleFonts.cairo(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w800)),
                            Text('درجة النجاح المطلوبة: $passingScore%',
                                style: GoogleFonts.cairo(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
              ],

              // Action Button (Dismiss / Close)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'حسناً، فهمت',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
