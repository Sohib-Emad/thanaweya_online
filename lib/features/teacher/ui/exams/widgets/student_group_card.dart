import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_results_helpers.dart';

/// Card displaying one student's name, attempts, and a reopen action.
///
/// Shows a header with avatar and best-score chip, followed by a list
/// of individual attempt rows with scores and timestamps.
class StudentGroupCard extends StatelessWidget {
  const StudentGroupCard({
    super.key,
    required this.studentId,
    required this.attempts,
    required this.onReopen,
  });

  final String studentId;
  final List<Map<String, dynamic>> attempts;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final name = ExamResultsHelpers.studentName(attempts);
    final bestPercent = ExamResultsHelpers.bestPercent(attempts);
    final passed = bestPercent >= 50;
    final statusColor = passed ? DeskColors.success : DeskColors.danger;

    return DeskCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DeskAvatar(initial: name, radius: 16),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: DeskText.strong(14.sp),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 3.h),
                    Text('المحاولات: ${attempts.length}', style: DeskText.note(10.5.sp)),
                  ],
                ),
              ),
              DeskStatusChip(
                label: 'أفضل نتيجة: ${bestPercent.toStringAsFixed(0)}%',
                color: statusColor,
              ),
              SizedBox(width: 8.w),
              DeskIconAction(
                icon: Icons.lock_open_rounded,
                color: DeskColors.primary,
                tooltip: 'إعادة فتح الامتحان لهذا الطالب',
                onTap: onReopen,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(height: 1, color: DeskColors.line),
          SizedBox(height: 6.h),
          ...attempts.asMap().entries.map((entry) {
            return _AttemptRow(
              index: entry.key,
              submission: entry.value,
            );
          }),
        ],
      ),
    );
  }
}

class _AttemptRow extends StatelessWidget {
  const _AttemptRow({required this.index, required this.submission});

  final int index;
  final Map<String, dynamic> submission;

  @override
  Widget build(BuildContext context) {
    final score = (submission['score'] as num?)?.toDouble();
    final total = (submission['total_points'] as num?)?.toInt() ?? 0;
    final submittedAt = submission['submitted_at'] as String?;
    final completed = score != null && submittedAt != null;
    final percent = completed && total > 0
        ? (score / total * 100).clamp(0, 100)
        : 0.0;
    final pctColor = completed && percent >= 50
        ? DeskColors.success
        : DeskColors.danger;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          _AttemptCircle(index: index, color: pctColor),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              completed
                  ? Formatters.formatDateTime(DateTime.parse(submittedAt))
                  : 'بدأ ولم يسلم الإجابة',
              style: DeskText.note(10.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(completed ? '${score.toStringAsFixed(0)} / $total' : '—',
              style: DeskText.strong(12.sp)),
          SizedBox(width: 10.w),
          DeskStatusChip(
            label: completed ? '${percent.toStringAsFixed(0)}%' : 'لم يكتمل',
            color: completed ? pctColor : DeskColors.accent,
          ),
        ],
      ),
    );
  }
}

class _AttemptCircle extends StatelessWidget {
  const _AttemptCircle({required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text('${index + 1}',
          style: DeskText.strong(10.sp, color: color)),
    );
  }
}
