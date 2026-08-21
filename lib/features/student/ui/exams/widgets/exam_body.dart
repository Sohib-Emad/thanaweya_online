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
    final isUrgent = secondsRemaining <= 300; // last 5 minutes
    final (imageUrl, cleanText) = _parseQuestionContent(question);

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
            // Offline warning banner
            if (state.isOffline) _OfflineBanner(),
            _buildTimerRow(context, currentIndex, questions.length, isUrgent),
            _buildProgressBar(currentIndex, questions.length, isUrgent),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cleanText.isNotEmpty)
                            Text(
                              cleanText,
                              style: NotebookText.body(15.sp).copyWith(height: 1.5),
                            ),
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            QuestionImageView(imageUrl: imageUrl),
                        ],
                      ),
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

  Widget _buildTimerRow(
      BuildContext context, int currentIndex, int total, bool isUrgent) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ExamTimerChip(
            secondsRemaining: secondsRemaining,
            formattedTime: formattedTime,
            isUrgent: isUrgent,
          ),
          Text(context.l10n.questionOf(currentIndex + 1, total),
              style: NotebookText.strong(13.sp)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentIndex, int total, bool isUrgent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: LinearProgressIndicator(
          value: (currentIndex + 1) / total,
          minHeight: 6.h,
          backgroundColor: NotebookColors.ink.withAlpha(22),
          valueColor: AlwaysStoppedAnimation(
            isUrgent ? NotebookColors.marginRed : NotebookColors.green,
          ),
        ),
      ),
    );
  }

  static (String?, String) _parseQuestionContent(QuestionModel question) {
    if (question.imageUrl != null && question.imageUrl!.trim().isNotEmpty) {
      return (question.imageUrl!.trim(), question.text);
    }

    final raw = question.text;

    // 1. Markdown image syntax: ![alt](https://...)
    final mdRegex = RegExp(r'!\[.*?\]\((https?://[^\s\)]+)\)');
    final mdMatch = mdRegex.firstMatch(raw);
    if (mdMatch != null) {
      final imgUrl = mdMatch.group(1);
      final cleanText = raw.replaceFirst(mdMatch.group(0)!, '').trim();
      return (imgUrl, cleanText);
    }

    // 2. Custom [image:URL] or [img:URL] tag
    final tagRegex = RegExp(
      r'\[(?:image|img|صورة):\s*(https?://[^\]]+)\]',
      caseSensitive: false,
    );
    final tagMatch = tagRegex.firstMatch(raw);
    if (tagMatch != null) {
      final imgUrl = tagMatch.group(1)?.trim();
      final cleanText = raw.replaceFirst(tagMatch.group(0)!, '').trim();
      return (imgUrl, cleanText);
    }

    // 3. Direct URL ending in image extension
    final urlRegex = RegExp(
      r'(https?://[^\s]+\.(?:png|jpg|jpeg|webp|gif|svg)(?:\?[^\s]*)?)',
      caseSensitive: false,
    );
    final urlMatch = urlRegex.firstMatch(raw);
    if (urlMatch != null) {
      final imgUrl = urlMatch.group(1);
      final cleanText = raw.replaceFirst(urlMatch.group(0)!, '').trim();
      return (imgUrl, cleanText);
    }

    return (null, raw);
  }
}

/// Shown when the device has no internet connectivity during the exam.
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      color: const Color(0xFFD97706),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14.r),
          SizedBox(width: 6.w),
          Text(
            'أنت غير متصل بالإنترنت — إجاباتك محفوظة محلياً',
            style: NotebookText.strong(10.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
