import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exam_results_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/reset_confirm_dialog.dart';

/// Reset/reopen actions for the exam results screen.
abstract final class ExamResultsActions {
  /// Shows a confirmation dialog and resets one student's attempts.
  static Future<void> resetStudent(
    BuildContext context, {
    required TeacherExamResultsCubit cubit,
    required String examId,
    required String studentId,
    required String studentName,
  }) async {
    final ok = await ResetConfirmDialog.show(
      context,
      title: 'إعادة فتح الامتحان',
      message:
          'سيتم حذف كل محاولات «$studentName» في هذا الامتحان ليتمكن من إعادته من جديد. هل أنت متأكد؟',
      confirmLabel: 'إعادة الفتح',
    );
    if (ok == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await cubit.resetStudentAttempts(examId: examId, studentId: studentId);
      if (context.mounted) _showSnack(context, 'تم إعادة فتح الامتحان للطالب');
    }
  }

  /// Shows a confirmation dialog and resets all students' attempts.
  static Future<void> resetAll(
    BuildContext context, {
    required TeacherExamResultsCubit cubit,
    required String examId,
  }) async {
    final ok = await ResetConfirmDialog.show(
      context,
      title: 'إعادة فتح الامتحان للجميع',
      message:
          'سيتم حذف كل محاولات جميع الطلاب في هذا الامتحان ليتمكنوا من إعادته من جديد. هل أنت متأكد؟',
      confirmLabel: 'إعادة الفتح للجميع',
    );
    if (ok == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await cubit.resetAllAttempts(examId);
      if (context.mounted) _showSnack(context, 'تم إعادة فتح الامتحان لجميع الطلاب');
    }
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: DeskColors.primaryDeep,
      content: Text(msg, style: DeskText.strong(12)),
    ));
  }
}
