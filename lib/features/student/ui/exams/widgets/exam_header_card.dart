import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/exam_info_widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Header card displayed on the exam start screen showing title,
/// instructor, and quick stats.
class ExamHeaderCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String duration;
  final String questionsCount;
  final String totalMarks;

  const ExamHeaderCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.questionsCount,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NotebookCard(
      ruled: true,
      ruledStartY: 104,
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: NotebookColors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 28.r,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: NotebookText.heading(17.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.responsibleTeacher(
              instructor.isEmpty ? l10n.teacherRole : instructor,
            ),
            style: NotebookText.note(11.sp),
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: NotebookColors.ink.withAlpha(35)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ExamStatItem(
                label: l10n.durationStat,
                value: duration,
                icon: Icons.timer_outlined,
              ),
              ExamStatItem(
                label: l10n.questionCountStat,
                value: questionsCount,
                icon: Icons.help_outline_rounded,
              ),
              ExamStatItem(
                label: l10n.totalScoreStat,
                value: totalMarks,
                icon: Icons.stars_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
