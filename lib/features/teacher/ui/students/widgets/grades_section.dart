import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/attempt_row.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/stat_cell.dart';

/// Section that displays the student's exam grades as a summary card
/// plus a detailed list of attempts grouped by exam.
class GradesSection extends StatelessWidget {
  final List<Map<String, dynamic>> grades;

  const GradesSection({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const DeskEmptyNote(
        message: 'لا توجد درجات بعد',
        subMessage: 'عندما يؤدي الطالب امتحاناتك ستظهر درجاته هنا',
        icon: Icons.grade_outlined,
      );
    }
    return Column(children: [_buildStatsCard(), SizedBox(height: 10.h), _buildGradesList()]);
  }

  double _percentOf(Map<String, dynamic> s) {
    final score = (s['score'] as num?)?.toDouble();
    final total = (s['total_points'] as num?)?.toDouble() ?? 0;
    if (score == null || total <= 0) return 0;
    return (score / total * 100).clamp(0, 100);
  }

  Map<String, List<Map<String, dynamic>>> _groupByExam() {
    final byExam = <String, List<Map<String, dynamic>>>{};
    for (final g in grades) {
      final examId = g['exam_id'] as String? ?? '';
      if (examId.isEmpty) continue;
      byExam.putIfAbsent(examId, () => []).add(g);
    }
    return byExam;
  }

  double _bestPercent(List<Map<String, dynamic>> attempts) {
    double best = 0;
    for (final s in attempts) {
      final p = _percentOf(s);
      if (p > best) best = p;
    }
    return best;
  }

  Widget _buildStatsCard() {
    final byExam = _groupByExam();
    final examCount = byExam.length;
    double best = 0;
    double sum = 0;
    for (final g in byExam.values) {
      final b = _bestPercent(g);
      if (b > best) best = b;
      sum += b;
    }
    final avg = examCount == 0 ? 0.0 : sum / examCount;

    return DeskCard(
      accent: DeskColors.primary,
      child: Row(children: [
        StatCell(label: 'امتحانات تم أداؤها', value: '$examCount', accent: DeskColors.primary),
        _div(),
        StatCell(label: 'أعلى درجة', value: '${best.round()}%', accent: DeskColors.success),
        _div(),
        StatCell(label: 'متوسط الدرجات', value: '${avg.round()}%', accent: DeskColors.accent),
      ]),
    );
  }

  Widget _div() => Container(width: 1, height: 30.h, color: DeskColors.line);

  Widget _buildGradesList() {
    final children = <Widget>[];
    _groupByExam().forEach((_, attempts) {
      final exam = attempts.first['exams'] as Map<String, dynamic>? ?? {};
      final title = exam['title'] as String? ?? 'امتحان';
      final maxScore = (exam['max_score'] as num?)?.toDouble() ??
          (attempts.first['total_points'] as num?)?.toDouble() ?? 100;
      final best = _bestPercent(attempts);
      children.add(DeskCard(
        accent: best >= 50 ? DeskColors.success : DeskColors.danger,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: DeskText.strong(14.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
            DeskStatusChip(label: 'أفضل نتيجة: ${best.round()}%', color: best >= 50 ? DeskColors.success : DeskColors.danger),
          ]),
          SizedBox(height: 8.h),
          for (int i = 0; i < attempts.length; i++)
            AttemptRow(attempt: attempts[i], index: i + 1, maxScore: maxScore),
        ]),
      ));
      children.add(SizedBox(height: 10.h));
    });
    return Column(children: children);
  }
}
