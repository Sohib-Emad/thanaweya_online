import 'package:thanaweya_online/features/teacher/ui/exams/widgets/exam_grades_summary.dart';

/// Computes per-exam grade summaries from raw submission rows.
class GradesSummaryComputer {
  /// Builds a map of exam ID → [ExamGradesSummary] from submission data.
  static Map<String, ExamGradesSummary> compute(
    List<Map<String, dynamic>> submissions,
  ) {
    final completedByExam = <String, List<Map<String, dynamic>>>{};
    for (final s in submissions) {
      if (s['submitted_at'] == null || s['score'] == null) continue;
      final examId = s['exam_id'] as String? ?? '';
      if (examId.isEmpty) continue;
      completedByExam.putIfAbsent(examId, () => []).add(s);
    }
    final result = <String, ExamGradesSummary>{};
    completedByExam.forEach((examId, rows) {
      final bestByStudent = <String, double>{};
      double bestOverall = 0;
      for (final s in rows) {
        final p = _percentOf(s);
        if (p > bestOverall) bestOverall = p;
        final sid = s['student_id'] as String? ?? '';
        if (p > (bestByStudent[sid] ?? 0)) bestByStudent[sid] = p;
      }
      final participants = bestByStudent.length;
      final avg = participants == 0
          ? 0.0
          : bestByStudent.values.reduce((a, b) => a + b) / participants;
      result[examId] = ExamGradesSummary(participants, bestOverall, avg);
    });
    return result;
  }

  static double _percentOf(Map<String, dynamic> row) {
    final score = (row['score'] as num?)?.toDouble();
    final total = (row['total_points'] as num?)?.toDouble() ?? 0;
    if (score == null || total <= 0) return 0;
    return (score / total * 100).clamp(0, 100);
  }
}
