import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/exam_warning_banner.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/result_paper_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen displaying the result of a submitted exam.
class ExamResultScreen extends StatelessWidget {
  final Map<String, dynamic>? resultData;

  const ExamResultScreen({super.key, this.resultData});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Map<String, dynamic> args =
        resultData ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {});

    final int score = args['score'] ?? 0;
    final int total = args['total'] ?? 0;
    final bool autoSubmitted = args['autoSubmitted'] ?? false;
    final bool isTimeOut = args['isTimeOut'] ?? false;
    final String examId = args['examId'] ?? '';
    final String examTitle = args['examTitle'] ?? '';
    final int maxAttempts = args['maxAttempts'] ?? 3;
    final int attemptNumber = args['attemptNumber'] ?? 1;
    final bool attemptsExhausted = attemptNumber >= maxAttempts;
    final double percent = total > 0 ? (score / total) * 100 : 0;
    final isPass = percent >= 50;

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.examResultTitle,
        subtitle: isPass ? l10n.gradedSaved : l10n.gradedSuccess,
      ),
      body: NotebookPaper(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (autoSubmitted) const AutoSubmitWarningBanner(),
              if (isTimeOut) const TimeoutWarningBanner(),
              ResultPaperCard(score: score, total: total, isPass: isPass),
              SizedBox(height: 36.h),
              if (examId.isNotEmpty) ...[
                _buildAttemptInfo(
                  l10n, attemptsExhausted, attemptNumber, maxAttempts,
                ),
                SizedBox(height: 20.h),
              ],
              if (examId.isNotEmpty)
                NotebookPrimaryButton(
                  label: l10n.viewAllResults,
                  icon: Icons.insights_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(
                      context,
                      AppRouter.studentExamAttempts,
                      arguments: {
                        'examId': examId,
                        'examTitle': examTitle,
                      },
                    );
                  },
                ),
              SizedBox(height: 12.h),
              NotebookPrimaryButton(
                label: l10n.backToExams,
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttemptInfo(
    AppLocalizations l10n,
    bool exhausted,
    int attempt,
    int max,
  ) {
    final accent = exhausted ? NotebookColors.marginRed : NotebookColors.green;
    return NotebookHighlightNote(
      child: Row(
        children: [
          Icon(
            exhausted ? Icons.lock_rounded : Icons.repeat_rounded,
            color: accent,
            size: 18.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              exhausted
                  ? l10n.attemptInfoExhausted(attempt, max)
                  : l10n.attemptInfoRemaining(attempt, max, max - attempt),
              style: NotebookText.strong(11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
