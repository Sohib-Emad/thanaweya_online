import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_card_header.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_section.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_summary.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_meta.dart';

/// A raised card displaying an exam's details, metadata, grades, and actions.
class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final String? courseTitle;
  final int questionCount;
  final int totalPoints;
  final ExamGradesSummary grades;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResults;
  final VoidCallback onTogglePublish;

  const ExamCard({
    super.key,
    required this.exam,
    required this.courseTitle,
    required this.questionCount,
    required this.totalPoints,
    required this.grades,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onResults,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final published = exam.isPublished;
    final accent = published ? DeskColors.success : DeskColors.accent;
    return DeskCard(
      accent: accent,
      label: published ? 'منشور' : 'مسودة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExamCardHeader(title: exam.title, courseTitle: courseTitle, accent: accent),
                SizedBox(height: 12.h),
                _buildMeta(),
                SizedBox(height: 12.h),
                ExamGradesSection(grades: grades),
              ],
            ),
          ),
          _buildFooter(published),
        ],
      ),
    );
  }

  Widget _buildMeta() {
    return Wrap(
      spacing: 14.w,
      runSpacing: 8.h,
      children: [
        ExamMeta(icon: Icons.timer_outlined, text: '${exam.durationMinutes} دقيقة'),
        ExamMeta(icon: Icons.calendar_month_outlined, text: '${Formatters.formatDate(exam.startAt)} إلى ${Formatters.formatDate(exam.endAt)}'),
        ExamMeta(icon: Icons.help_outline_rounded, text: '$questionCount سؤال'),
        if (totalPoints > 0) ExamMeta(icon: Icons.stars_outlined, text: '$totalPoints نقطة'),
      ],
    );
  }

  Widget _buildFooter(bool published) {
    return DeskActionFooter(
      actions: [
        DeskLabeledAction(label: 'النتائج', icon: Icons.bar_chart_rounded, color: DeskColors.info, onTap: onResults),
        DeskLabeledAction(label: published ? 'إلغاء النشر' : 'نشر', icon: published ? Icons.visibility_off_outlined : Icons.publish_rounded, color: published ? DeskColors.accent : DeskColors.success, onTap: onTogglePublish),
        DeskLabeledAction(label: 'تعديل', icon: Icons.edit_outlined, color: DeskColors.primary, onTap: onEdit),
        DeskLabeledAction(label: 'حذف', icon: Icons.delete_outline_rounded, color: DeskColors.danger, onTap: onDelete),
      ],
    );
  }
}
