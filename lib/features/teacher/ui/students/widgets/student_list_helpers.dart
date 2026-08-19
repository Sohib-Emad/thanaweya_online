import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Filters a student list by search query and grade level.
List<Map<String, dynamic>> filterStudents({
  required List<Map<String, dynamic>> students,
  required String searchQuery,
  required String gradeFilter,
}) {
  final q = searchQuery.toLowerCase();
  return students.where((s) {
    final user = s['users'] as Map<String, dynamic>? ?? {};
    final name = (user['full_name'] as String? ?? '').toLowerCase();
    final email = (user['email'] as String? ?? '').toLowerCase();
    final phone = (user['phone'] as String? ?? '').toLowerCase();
    final grade = (s['students'] as Map<String, dynamic>?)?['grade_level'] as String? ?? '';
    final matchesQuery = name.contains(q) || email.contains(q) || phone.contains(q);
    final matchesGrade = gradeFilter.isEmpty || grade == gradeFilter;
    return matchesQuery && matchesGrade;
  }).toList();
}

/// Empty-state widget used when no students match.
class StudentsEmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StudentsEmptyState({
    super.key,
    required this.message,
    this.subMessage,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DeskEmptyNote(
        message: message,
        subMessage: subMessage,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
