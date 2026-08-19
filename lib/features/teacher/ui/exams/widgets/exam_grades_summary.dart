/// Data class representing a summary of exam grades.
class ExamGradesSummary {
  /// Number of students who participated.
  final int participants;

  /// Best percentage score achieved.
  final double bestPercent;

  /// Average percentage score across participants.
  final double averagePercent;

  const ExamGradesSummary(
    this.participants,
    this.bestPercent,
    this.averagePercent,
  );
}
