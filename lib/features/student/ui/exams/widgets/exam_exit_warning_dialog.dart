import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Warning dialog shown when the user attempts to exit during an exam.
class ExamExitWarningDialog extends StatelessWidget {
  final VoidCallback onSubmit;

  const ExamExitWarningDialog({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NotebookColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.report_problem_rounded,
            color: NotebookColors.marginRed,
            size: 26.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.l10n.exitBlockedTitle,
              style: NotebookText.heading(16.sp),
            ),
          ),
        ],
      ),
      content: Text(
        context.l10n.exitBlockedMessage,
        style: NotebookText.body(13.sp, color: NotebookColors.pencil)
            .copyWith(height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancelAndContinue,
            style: NotebookText.strong(13.sp, color: NotebookColors.green),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onSubmit();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NotebookColors.marginRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            context.l10n.submitNow,
            style: NotebookText.strong(13.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
