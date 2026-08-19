import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Full exam body with timer header, question grid, options, and bottom bar.
class ExamBody extends StatelessWidget {
  final StudentExamsState state;
  final int secondsRemaining;
  final String formattedTime;
  final StudentExamsCubit cubit;
  final VoidCallback onSubmit;

  const ExamBody({
    super.key,
    required this.state,
    required this.secondsRemaining,
    required this.formattedTime,
    required this.cubit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final questions = state.currentQuestions;
    final currentIndex = state.currentQuestionIndex;
    final question = questions[currentIndex];
    final options = question.options;
    final letters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    final isEssay = question.questionType == QuestionType.essay;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (_) => ExamExitWarningDialog(onSubmit: onSubmit),
        );
      },
      child: NotebookPaper(
        child: Column(
          children: [
            ExamMonitoringBanner(message: context.l10n.monitoringBanner),
            _buildTimerRow(context, currentIndex, questions.length),
            _buildProgressBar(currentIndex, questions.length),
            SizedBox(height: 12.h),
            QuestionNavigatorGrid(
              totalQuestions: questions.length,
              currentIndex: currentIndex,
              answeredIds: state.answers.keys.toSet(),
              questionIds: questions.map((q) => q.id).toList(),
              onTap: cubit.goToQuestion,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotebookCard(
                      ruled: true,
                      ruledStartY: 40,
                      child: Text(question.text,
                          style: NotebookText.body(15.sp).copyWith(height: 1.5)),
                    ),
                    SizedBox(height: 16.h),
                    if (isEssay)
                      ExamEssayField(
                        value: state.answers[question.id] ?? '',
                        onChanged: (v) => cubit.selectAnswer(question.id, v),
                      )
                    else if (options.isNotEmpty)
                      ...List.generate(options.length, (i) {
                        return ExamOptionTile(
                          optionText: options[i],
                          isSelected: state.answers[question.id] == options[i],
                          letter: i < letters.length ? letters[i] : '${i + 1}',
                          onTap: () => cubit.selectAnswer(question.id, options[i]),
                        );
                      })
                    else
                      Padding(
                        padding: EdgeInsets.all(20.r),
                        child: Center(
                          child: Text(context.l10n.noOptionsAvailable,
                              style: NotebookText.note(13.sp)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ExamBottomBar(
              currentIndex: currentIndex,
              totalQuestions: questions.length,
              onPrevious: cubit.previousQuestion,
              onNext: cubit.nextQuestion,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerRow(BuildContext context, int currentIndex, int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ExamTimerChip(
              secondsRemaining: secondsRemaining, formattedTime: formattedTime),
          Text(context.l10n.questionOf(currentIndex + 1, total),
              style: NotebookText.strong(13.sp)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentIndex, int total) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: LinearProgressIndicator(
          value: (currentIndex + 1) / total,
          minHeight: 6.h,
          backgroundColor: NotebookColors.ink.withAlpha(22),
          valueColor: AlwaysStoppedAnimation(NotebookColors.green),
        ),
      ),
    );
  }
}
