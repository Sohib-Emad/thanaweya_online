/// Data class holding user-selected course filters.
class CourseFilters {
  const CourseFilters({
    this.subjectIds = const {},
    this.stages = const {},
  });

  /// Selected subject IDs.
  final Set<String> subjectIds;

  /// Selected stage keys.
  final Set<String> stages;

  /// Whether any filter is active.
  bool get isActive => subjectIds.isNotEmpty || stages.isNotEmpty;

  /// Whether a course map passes the filter.
  bool matches(Map<String, dynamic> course) {
    if (subjectIds.isNotEmpty) {
      final subjectId = course['subject_id'] as String?;
      if (subjectId == null || !subjectIds.contains(subjectId)) return false;
    }
    if (stages.isNotEmpty) {
      final stage = course['stage'] as String?;
      if (stage == null || !stages.contains(stage)) return false;
    }
    return true;
  }
}
