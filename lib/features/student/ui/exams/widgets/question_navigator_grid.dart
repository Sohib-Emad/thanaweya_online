import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Horizontal scrollable grid of question number indicators.
class QuestionNavigatorGrid extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Set<String> answeredIds;
  final List<String> questionIds;
  final ValueChanged<int> onTap;

  const QuestionNavigatorGrid({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answeredIds,
    required this.questionIds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(totalQuestions, (index) {
          final isAnswered = answeredIds.contains(questionIds[index]);
          final isCurrent = index == currentIndex;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(index);
            },
            child: Container(
              margin: EdgeInsets.only(left: 8.w),
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: isCurrent
                    ? NotebookColors.green
                    : isAnswered
                        ? NotebookColors.surfaceBright
                        : NotebookColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent
                      ? NotebookColors.green
                      : isAnswered
                          ? NotebookColors.green
                          : NotebookColors.ink.withAlpha(55),
                  width: isCurrent ? 1.5 : 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: NotebookText.strong(
                    12.sp,
                    color: isCurrent
                        ? Colors.white
                        : isAnswered
                            ? NotebookColors.green
                            : NotebookColors.pencil,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
