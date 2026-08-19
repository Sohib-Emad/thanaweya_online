import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Shows a confirmation dialog before starting an exam.
void showStartConfirmationDialog(
  BuildContext context, {
  required String examId,
  required String examTitle,
  required int maxAttempts,
  required int attemptsUsed,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: NotebookColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: NotebookColors.marginRed,
            size: 26.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.l10n.confirmStartTitle,
              style: NotebookText.heading(16.sp),
            ),
          ),
        ],
      ),
      content: Text(
        context.l10n.confirmStartMessage,
        style: NotebookText.body(13.sp, color: NotebookColors.pencil)
            .copyWith(height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancel,
            style: NotebookText.strong(13.sp, color: NotebookColors.pencil),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(
              context,
              AppRouter.studentExamTaking,
              arguments: {
                'examId': examId,
                'examTitle': examTitle,
                'maxAttempts': maxAttempts,
                'attemptsUsed': attemptsUsed,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NotebookColors.marginRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            context.l10n.startExamNow,
            style: NotebookText.strong(13.sp, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
