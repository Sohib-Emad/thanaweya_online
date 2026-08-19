import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Dialog shown when exam attempts are exhausted.
class ExamLockedDialog extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback onViewResults;

  const ExamLockedDialog({
    super.key,
    required this.exam,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NotebookColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(
        children: [
          Icon(Icons.lock_rounded, color: NotebookColors.marginRed, size: 24.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.l10n.examAttemptsExhaustedTitle,
              style: NotebookText.heading(16.sp),
            ),
          ),
        ],
      ),
      content: Text(
        context.l10n.examAttemptsExhaustedMessage(
          (exam['max_attempts'] as int?) ?? 3,
        ),
        style: NotebookText.body(13.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel, style: NotebookText.strong(13.sp)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onViewResults();
          },
          child: Text(
            context.l10n.viewResults,
            style: NotebookText.strong(13.sp, color: NotebookColors.green),
          ),
        ),
      ],
    );
  }
}
