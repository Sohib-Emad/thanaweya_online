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

  /// Calculates total watched minutes across all lessons.
  static int calculateTotalWatchedMinutes(List<Map<String, dynamic>> progress) {
    int totalSec = 0;
    for (final p in progress) {
      totalSec += (p['watched_seconds'] as num?)?.toInt() ?? 0;
    }
    return (totalSec / 60).round();
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
    if (overall >= 88) return 'ممتاز 🌟';
    if (overall >= 75) return 'جيد جداً 👏';
    if (overall >= 60) return 'جيد 👍';
    return 'يحتاج لمتابعة ⚠️';
  }

  /// Returns the color associated with a grade rating text.
  static Color overallGradeColor(String gradeText) {
    if (gradeText.contains('ممتاز')) return const Color(0xFF10B981);
    if (gradeText.contains('جيد جداً')) return const Color(0xFF0284C7);
    if (gradeText.contains('جيد')) return const Color(0xFFF59E0B);
    if (gradeText.contains('متابعة')) return const Color(0xFFEF4444);
    return DeskColors.muted;
  }

  /// Builds a rich, comprehensive, and beautiful formatted WhatsApp report.
  static String buildFormattedReportText({
    required String studentName,
    required String gradeLevel,
    required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> progress,
    List<Map<String, dynamic>> courses = const [],
    required String customNotes,
  }) {
    final examAvg = calculateExamAverage(grades);
    final lessonRate = calculateLessonCompletionRate(progress);
    final gradeRating =
        calculateOverallGradeText(examAvg, lessonRate, grades, progress);
    final watchedMinutes = calculateTotalWatchedMinutes(progress);
    final completedCount = progress.where((p) {
      return p['is_completed'] == true ||
          (p['watched_seconds'] as num? ?? 0) > 0 ||
          (p['view_count'] as num? ?? 0) > 0;
    }).length;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🎓 *تقرير أداء ومتابعة الطالب* 🎓');
    buffer.writeln('منصة *ثانوية أونلاين* التعليمية');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('👤 *اسم الطالب:* $studentName');
    if (gradeLevel.isNotEmpty) {
      buffer.writeln('📚 *المرحلة الدراسية:* $gradeLevel');
    }
    buffer.writeln('🏆 *التقييم العام:* $gradeRating');
    buffer.writeln();

    // ── 1. Enrolled Courses ──
    if (courses.isNotEmpty) {
      buffer.writeln('📖 *الكورسات المسجل بها (${courses.length}):*');
      for (final c in courses) {
        final title = c['title'] as String? ?? 'كورس تعليمي';
        buffer.writeln('  ▫️ $title');
      }
      buffer.writeln();
    }

    // ── 2. Exam Results Breakdown ──
    buffer.writeln('📊 *نتائج الامتحانات والاختبارات:*');
    buffer.writeln('• متوسط درجات الامتحانات: *${examAvg.toStringAsFixed(1)}%*');
    if (grades.isEmpty) {
      buffer.writeln('  (لم يؤدِ الطالب أي امتحانات حتى الآن)');
    } else {
      buffer.writeln('• عدد الامتحانات المكتملة: ${grades.length}');
      buffer.writeln();
      buffer.writeln('📝 *تفاصيل درجات الامتحانات:*');
      for (final g in grades) {
        final examTitle = (g['exams'] as Map?)?['title'] as String? ??
            g['exam_title'] as String? ??
            'اختبار';
        final score = (g['score'] as num?)?.toInt() ?? 0;
        final total = (g['total_points'] as num?)?.toInt() ??
            ((g['exams'] as Map?)?['max_score'] as num?)?.toInt() ??
            100;
        final passingScore =
            ((g['exams'] as Map?)?['passing_score'] as num?)?.toInt() ?? 50;
        final pct = total > 0 ? ((score / total) * 100).round() : 0;
        final passed = pct >= passingScore;
        final statusEmoji = passed ? '✅ ناجح' : '⚠️ يحتاج تحسين';

        buffer.writeln('  ▫️ *$examTitle*: $score / $total ($pct%) — $statusEmoji');
      }
    }
    buffer.writeln();

    // ── 3. Lessons & Attendance Breakdown ──
    buffer.writeln('🎬 *حضور ومشاهدة المحاضرات:*');
    buffer.writeln('• نسبة الحضور والاكتمال: *${lessonRate.toStringAsFixed(1)}%*');
    buffer.writeln('• الحصص المشاهدة: $completedCount من إجمالي ${progress.length} حصة');
    if (watchedMinutes > 0) {
      buffer.writeln('• إجمالي وقت الاستماع: $watchedMinutes دقيقة');
    }
    buffer.writeln();

    // ── 4. Teacher Notes ──
    if (customNotes.isNotEmpty) {
      buffer.writeln('💡 *ملاحظات وتوصيات المعلم لولي الأمر:*');
      buffer.writeln(customNotes);
      buffer.writeln();
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('✨ مع تمنياتنا للطالب بدوام التفوق والنجاح.');
    buffer.writeln('📱 للتواصل والمتابعة المباشرة مع المعلم.');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }
}
