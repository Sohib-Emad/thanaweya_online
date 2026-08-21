import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// List of the most challenging exams with failure rates
/// and average scores dynamically calculated from teacher's exams.
class ChallengingExamsList extends StatelessWidget {
  final List<Map<String, dynamic>> exams;

  const ChallengingExamsList({
    super.key,
    this.exams = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasData = exams.isNotEmpty;

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
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 20.r, color: const Color(0xFFD97706)),
              SizedBox(width: 8.w),
              Text('أكثر الامتحانات صعوبة',
                  style: DeskText.heading(13.5.sp)),
            ],
          ),
          SizedBox(height: 12.h),
          if (!hasData) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 14.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Icons.task_alt_rounded,
                      size: 32.r, color: const Color(0xFF94A3B8)),
                  SizedBox(height: 8.h),
                  Text(
                    'لا توجد امتحانات مكتملة بعد في هذه الفترة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'عندما يحل طلابك الاختبارات، ستظهر هنا الامتحانات التي واجه الطلاب صعوبة فيها لمراجعتها.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exams.length,
              separatorBuilder: (_, _) => const Divider(height: 14),
              itemBuilder: (context, i) {
                final ex = exams[i];
                final exColor = Color(ex['color'] as int? ?? 0xFFE11D48);
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 12.r,
                      backgroundColor: exColor.withValues(alpha: 0.15),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: exColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex['title'] as String? ?? 'امتحان',
                            style: DeskText.strong(12.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'نسبة عدم الاجتياز: ${ex['failRate']}',
                            style: DeskText.note(10.5.sp),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'متوسط: ${ex['avg']}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
