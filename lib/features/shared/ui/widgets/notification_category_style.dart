import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Returns the icon, color and label for a notification category.
({IconData icon, Color color, String label}) notificationCategoryStyle(
  String category,
  bool isTeacher,
) {
  switch (category) {
    case 'lessons':
      return (
        icon: Icons.play_circle_fill_rounded,
        color: isTeacher ? DeskColors.primary : NotebookColors.green,
        label: 'الدروس',
      );
    case 'exams':
      return (
        icon: Icons.assignment_turned_in_rounded,
        color: isTeacher ? DeskColors.info : const Color(0xFF3F7FBF),
        label: 'الامتحانات',
      );
    default:
      return (
        icon: Icons.verified_rounded,
        color: isTeacher ? DeskColors.accent : const Color(0xFFD97706),
        label: 'النظام',
      );
  }
}
