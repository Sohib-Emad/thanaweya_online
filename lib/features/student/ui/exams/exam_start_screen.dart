import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/exam_header_card.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/exam_info_widgets.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/start_confirmation_dialog.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen shown before starting an exam with instructions, rules,
/// and attempt status.
class ExamStartScreen extends StatelessWidget {
  final Map<String, dynamic>? examData;

  const ExamStartScreen({super.key, this.examData});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = examData?['title'] as String? ?? l10n.comprehensiveExam;
    final durationMinutes = examData?['duration_minutes'] as int? ?? 0;
    final duration = l10n.durationMinutes(durationMinutes);
    final questions = examData?['questions'];
    final questionsCount =
        (questions is List && questions.isNotEmpty
                ? (questions.first['count'] as int?) ?? 0
                : 0)
            .toString();
    final totalMarks = l10n.totalMarks('${examData?['max_score'] ?? 0}');
    final teachers = examData?['teachers'];
    final users = teachers is Map ? teachers['users'] : null;
    final instructor =
        users is Map ? (users['full_name'] as String? ?? '') : '';
    final examId = examData?['id'] as String? ?? '';
    final used = examData?['attempts_used'] as int? ?? 0;
    final maxAttempts = examData?['max_attempts'] as int? ?? 3;
    final locked = used >= maxAttempts;
    final remaining = (maxAttempts - used).clamp(0, maxAttempts);

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.examInstructionsTitle,
        subtitle: l10n.examInstructionsSubtitle,
      ),
      body: NotebookPaper(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExamHeaderCard(
                title: title,
                instructor: instructor,
                duration: duration,
                questionsCount: questionsCount,
                totalMarks: totalMarks,
              ),
              SizedBox(height: 20.h),
              NotebookSectionHeader(title: l10n.examRulesTitle),
              SizedBox(height: 8.h),
              _buildRulesNote(l10n),
              SizedBox(height: 20.h),
              AttemptsInfoCard(
                locked: locked,
                remaining: remaining,
                maxAttempts: maxAttempts,
                lockedTitle: l10n.attemptsFinished,
                unlockedTitle: l10n.remainingAttempts(remaining, maxAttempts),
                lockedMessage: l10n.attemptsFinishedMessage,
                unlockedMessage: l10n.retakeMessage(maxAttempts),
              ),
              SizedBox(height: 28.h),
              if (locked)
                NotebookPrimaryButton(
                  label: l10n.viewResults,
                  icon: Icons.insights_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(
                      context,
                      AppRouter.studentExamAttempts,
                      arguments: {
                        'examId': examId,
                        'examTitle': title,
                      },
                    );
                  },
                )
              else
                NotebookPrimaryButton(
                  label: l10n.startExamNow,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    showStartConfirmationDialog(
                      context,
                      examId: examId,
                      examTitle: title,
                      maxAttempts: maxAttempts,
                      attemptsUsed: used,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesNote(AppLocalizations l10n) {
    return NotebookHighlightNote(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_rounded,
                color: NotebookColors.marginRed,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.strictRulesNote,
                style: NotebookText.strong(12.sp, color: NotebookColors.marginRed),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ExamRuleItem(title: l10n.ruleTimingTitle, description: l10n.ruleTimingDesc),
          SizedBox(height: 8.h),
          ExamRuleItem(title: l10n.ruleNoExitTitle, description: l10n.ruleNoExitDesc),
          SizedBox(height: 8.h),
          ExamRuleItem(title: l10n.ruleConnectionTitle, description: l10n.ruleConnectionDesc),
        ],
      ),
    );
  }
}
