import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Bottom action bar with Previous / Next / Submit buttons for exam navigation.
class ExamBottomBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const ExamBottomBar({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex >= totalQuestions - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: NotebookColors.surfaceBright,
        border: Border(
          top: BorderSide(color: NotebookColors.ink.withAlpha(45)),
        ),
      ),
      child: Row(
        children: [
          if (currentIndex > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: NotebookColors.pencil),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  context.l10n.previousQuestion,
                  style: NotebookText.strong(13.sp, color: NotebookColors.pencil),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: isLast
                ? NotebookPrimaryButton(
                    label: context.l10n.submitExamLabel,
                    icon: Icons.flag_rounded,
                    onPressed: onSubmit,
                  )
                : NotebookPrimaryButton(
                    label: context.l10n.nextQuestion,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onNext,
                  ),
          ),
        ],
      ),
    );
  }
}
