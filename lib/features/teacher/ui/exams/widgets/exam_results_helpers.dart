/// Shared helper functions for exam results calculations.
///
/// Provides grouping, percentage, and scoring utilities used by
/// the results screen and its sub-widgets.
abstract final class ExamResultsHelpers {
  /// Extracts the student's full name from a submission map.
  static String studentName(List<Map<String, dynamic>> attempts) {
    final students = attempts.first['students'] as Map<String, dynamic>? ?? {};
    final users = students['users'] as Map<String, dynamic>? ?? {};
    return users['full_name'] as String? ?? 'طالب';
  }

  /// Groups submissions by student ID, sorted by best percentage descending.
  static Map<String, List<Map<String, dynamic>>> groupByStudent(
    List<Map<String, dynamic>> submissions,
  ) {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final s in submissions) {
      final studentId = s['student_id'] as String? ?? '';
      if (studentId.isEmpty) continue;
      groups.putIfAbsent(studentId, () => []).add(s);
    }
    final sorted = groups.entries.toList()
      ..sort((a, b) => bestPercent(b.value).compareTo(bestPercent(a.value)));
    return {for (final e in sorted) e.key: e.value};
  }

  /// Percentage score of a single submission, clamped 0–100.
  static double percentOf(Map<String, dynamic> s) {
    final score = (s['score'] as num?)?.toDouble();
    final total = (s['total_points'] as num?)?.toDouble() ?? 0;
    if (score == null || total <= 0) return 0;
    return (score / total * 100).clamp(0, 100);
  }

  /// Best percentage across a list of attempts for one student.
  static double bestPercent(List<Map<String, dynamic>> attempts) {
    double best = 0;
    for (final s in attempts) {
      final p = percentOf(s);
      if (p > best) best = p;
    }
    return best;
  }

  /// Global best percentage across all student groups.
  static double bestScore(Map<String, List<Map<String, dynamic>>> groups) {
    double best = 0;
    for (final g in groups.values) {
      final p = bestPercent(g);
      if (p > best) best = p;
    }
    return best;
  }

  /// Average of best percentages across all student groups.
  static double averageScore(Map<String, List<Map<String, dynamic>>> groups) {
    if (groups.isEmpty) return 0;
    double sum = 0;
    for (final g in groups.values) {
      sum += bestPercent(g);
    }
    return sum / groups.length;
  }
}
