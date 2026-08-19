import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';

/// Handles the publish-exam flow and shows success/error snackbars.
///
/// Returns `true` if the exam was published successfully (for navigation).
Future<bool> publishExam({
  required BuildContext context,
  required String userId,
  required String title,
  required String durationText,
  String? courseId,
  required List<Map<String, dynamic>> questions,
}) async {
  if (questions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('يرجى إضافة سؤال واحد على الأقل قبل نشر الامتحان')),
    );
    return false;
  }

  final duration = int.tryParse(durationText.trim()) ?? 45;
  final now = DateTime.now();

  try {
    final examRes = await TeacherExamsRepo().createExam(
      teacherId: userId,
      title: title,
      durationMinutes: duration,
      startAt: now,
      endAt: now.add(const Duration(days: 365)),
      courseId: courseId,
    );

    bool success = false;
    await examRes.when(
      success: (exam) async {
        for (final q in questions) {
          final rawType = q['type'] as String? ?? 'mcq';
          final qType = (rawType == 'true_false' || rawType == 'tf')
              ? 'true_false'
              : (rawType == 'essay' ? 'essay' : 'mcq');
          await TeacherExamsRepo().questions.addQuestion(
            examId: exam.id,
            questionType: qType,
            text: q['question'] as String? ?? '',
            options: (q['options'] as List<dynamic>?)?.cast<String>() ?? [],
            correctAnswer:
                (q['correct_answers'] as List<dynamic>?)?.firstOrNull?.toString() ?? '0',
            points: (q['points'] as int?) ?? 5,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم نشر الامتحان بنجاح!'),
              backgroundColor: DeskColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          success = true;
        }
      },
      failure: (msg, _) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('فشل إنشاء الامتحان: $msg'),
                backgroundColor: DeskColors.danger),
          );
        }
      },
    );
    return success;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: DeskColors.danger),
      );
    }
    return false;
  }
}
