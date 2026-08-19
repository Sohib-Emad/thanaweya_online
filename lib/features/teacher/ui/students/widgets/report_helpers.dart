import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Static helpers for parent report calculations and text formatting.
class ReportHelpers {
  const ReportHelpers._();

  /// Calculates the average exam score as a percentage.
  static double calculateExamAverage(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) return 0;
    double sum = 0;
    int count = 0;
    for (final g in grades) {
      final score = (g['score'] as num?)?.toDouble();
      final total = (g['total_points'] as num?)?.toDouble() ??
          ((g['exams'] as Map?)?['max_score'] as num?)?.toDouble() ??
          0;
      if (score != null) {
        if (total > 0) {
          sum += (score / total * 100).clamp(0, 100);
        } else {
          sum += score.clamp(0, 100);
        }
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  /// Calculates lesson completion rate as a percentage.
  static double calculateLessonCompletionRate(
    List<Map<String, dynamic>> progress,
  ) {
    if (progress.isEmpty) return 0;
    final completed = progress.where((p) {
      final isDone = p['is_completed'] == true ||
          p['is_completed'] == 1 ||
          p['is_completed'] == 'true';
      final watched = (p['watched_seconds'] as num?)?.toInt() ?? 0;
      final views = (p['view_count'] as num?)?.toInt() ?? 0;
      return isDone || watched > 0 || views > 0;
    }).length;
    return (completed / progress.length) * 100;
  }

  /// Calculates the overall grade text based on exam average and lesson rate.
  static String calculateOverallGradeText(
    double examAvg,
    double lessonRate,
    List<Map<String, dynamic>> grades,
    List<Map<String, dynamic>> progress,
  ) {
    if (grades.isEmpty && progress.isEmpty) return 'حديث الانضمام';
    final overall = (examAvg * 0.7) + (lessonRate * 0.3);
    if (overall >= 88) return 'ممتاز';
    if (overall >= 75) return 'جيد جداً';
    if (overall >= 60) return 'جيد';
    return 'يحتاج لمتابعة';
  }

  /// Returns the color associated with a grade rating text.
  static Color overallGradeColor(String gradeText) {
    if (gradeText.contains('ممتاز')) return const Color(0xFF10B981);
    if (gradeText.contains('جيد جداً')) return const Color(0xFF3B82F6);
    if (gradeText.contains('جيد')) return const Color(0xFFF59E0B);
    if (gradeText.contains('متابعة')) return const Color(0xFFEF4444);
    return DeskColors.muted;
  }

  /// Builds the formatted report text for sharing via WhatsApp or clipboard.
  static String buildFormattedReportText({
    required String studentName,
    required String gradeLevel,
    required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> progress,
    required String customNotes,
  }) {
    final examAvg = calculateExamAverage(grades);
    final lessonRate = calculateLessonCompletionRate(progress);
    final gradeRating =
        calculateOverallGradeText(examAvg, lessonRate, grades, progress);

    final buffer = StringBuffer();
    buffer.writeln('🎓 *تقرير أداء الطالب - ثانوية أونلاين* 🎓');
    buffer.writeln('---------------------------------------');
    buffer.writeln('👤 *اسم الطالب:* $studentName');
    if (gradeLevel.isNotEmpty) {
      buffer.writeln('📚 *الصف الدراسي:* $gradeLevel');
    }
    buffer.writeln('🏆 *التقدير العام:* $gradeRating');
    buffer.writeln();
    buffer.writeln('📊 *تفاصيل الأداء:*');
    buffer.writeln(
      '• متوسط درجات الامتحانات: ${examAvg.toStringAsFixed(1)}% '
      '(${grades.length} امتحان)',
    );
    final completedCount =
        progress.where((p) => p['is_completed'] == true).length;
    buffer.writeln(
      '• نسبة حضور واكتمال الدروس: ${lessonRate.toStringAsFixed(1)}% '
      '($completedCount/${progress.length} درس)',
    );

    if (grades.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('📝 *أحدث درجات الامتحانات:*');
      for (final g in grades.take(3)) {
        final examTitle =
            (g['exams'] as Map?)?['title'] as String? ?? 'امتحان';
        final score = g['score'] ?? 0;
        final total = g['total_points'] ?? 100;
        buffer.writeln('  - $examTitle: $score / $total');
      }
    }

    if (customNotes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('💡 *ملاحظات المعلم وتوصياته:*');
      buffer.writeln(customNotes);
    }

    buffer.writeln();
    buffer.writeln('---------------------------------------');
    buffer.writeln('✨ تحيات معلم المادة عبر منصة *ثانوية أونلاين*');

    return buffer.toString();
  }
}
