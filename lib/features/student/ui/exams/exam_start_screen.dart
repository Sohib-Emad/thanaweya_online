import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/exam_header_card.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/exam_info_widgets.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/start_confirmation_dialog.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen shown before starting an exam with instructions, rules,
/// window timing, and attempt status.
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
    final questionsCount = (examData?['questions_count'] as int? ??
            (questions is List && questions.isNotEmpty
                ? (questions.first['count'] as int?) ?? 0
                : 0))
        .toString();
    final totalMarks = l10n.totalMarks('${examData?['max_score'] ?? 0}');
    final passingScore = examData?['passing_score'] as int? ?? 50;
    final teachers = examData?['teachers'];
    final users = teachers is Map ? teachers['users'] : null;
    final instructor = examData?['teacher_name'] as String? ??
        (users is Map ? (users['full_name'] as String? ?? '') : '');
    final examId = examData?['id'] as String? ?? '';
    final used = examData?['attempts_used'] as int? ?? 0;
    final allowRetake = examData?['allow_retake'] as bool? ?? false;
    final maxAttempts = examData?['max_attempts'] as int? ?? (allowRetake ? 3 : 1);
    final locked = used >= maxAttempts;
    final remaining = (maxAttempts - used).clamp(0, maxAttempts);

    // Exam window checks
    final startAtStr = examData?['start_at'] as String?;
    final endAtStr = examData?['end_at'] as String?;
    final startAt = startAtStr != null ? DateTime.tryParse(startAtStr)?.toLocal() : null;
    final endAt = endAtStr != null ? DateTime.tryParse(endAtStr)?.toLocal() : null;

    final isUpcoming = startAt != null && DateTime.now().isBefore(startAt);
    final isExpired = endAt != null && DateTime.now().isAfter(endAt);

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
              SizedBox(height: 16.h),

              // Window timing banner if set
              if (startAt != null || endAt != null)
                _buildWindowCard(startAt, endAt, isUpcoming, isExpired),

              SizedBox(height: 16.h),
              NotebookSectionHeader(title: 'تعليمات قبل بدء الاختبار'),
              SizedBox(height: 8.h),
              _buildRulesNote(l10n, passingScore),
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
              else if (isUpcoming)
                NotebookPrimaryButton(
                  label: 'الاختبار لم يبدأ بعد',
                  icon: Icons.schedule_rounded,
                  onPressed: null,
                )
              else if (isExpired)
                NotebookPrimaryButton(
                  label: 'انتهت فترة الاختبار',
                  icon: Icons.timer_off_rounded,
                  onPressed: null,
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

  Widget _buildWindowCard(
      DateTime? startAt, DateTime? endAt, bool isUpcoming, bool isExpired) {
    final fmt = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    return NotebookCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired
                    ? Icons.timer_off_outlined
                    : isUpcoming
                        ? Icons.schedule
                        : Icons.check_circle_outline,
                color: isExpired
                    ? NotebookColors.marginRed
                    : isUpcoming
                        ? const Color(0xFFD97706)
                        : NotebookColors.green,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                isExpired
                    ? 'انتهت فترة الاختبار'
                    : isUpcoming
                        ? 'ميعاد الاختبار قريباً'
                        : 'الاختبار متاح الآن',
                style: NotebookText.strong(
                  13.sp,
                  color: isExpired
                      ? NotebookColors.marginRed
                      : isUpcoming
                          ? const Color(0xFFD97706)
                          : NotebookColors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (startAt != null)
            Text(
              'بداية الاختبار: ${fmt.format(startAt)}',
              style: NotebookText.note(11.5.sp),
            ),
          if (endAt != null)
            Text(
              'نهاية الاختبار: ${fmt.format(endAt)}',
              style: NotebookText.note(11.5.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildRulesNote(AppLocalizations l10n, int passingScore) {
    return NotebookHighlightNote(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: NotebookColors.ink,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'تنبيهات هامة للطالب',
                style: NotebookText.strong(12.sp, color: NotebookColors.ink),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ExamRuleItem(
            title: 'درجة النجاح',
            description: 'درجة النجاح في هذا الاختبار هي $passingScore%',
          ),
          SizedBox(height: 8.h),
          ExamRuleItem(
            title: 'بدء الوقت',
            description: 'يبدأ الـ Countdown بمجرد الضغط على بدء الاختبار ولا يمكن إيقافه.',
          ),
          SizedBox(height: 8.h),
          ExamRuleItem(
            title: 'استمرار الوقت عند الخروج',
            description: 'إغلاق التطبيق أو الهاتف لا يوقف المؤقت الزمني.',
          ),
          SizedBox(height: 8.h),
          ExamRuleItem(
            title: 'العمل بدون إنترنت',
            description: 'بعد تحميل الأسئلة يمكنك الاستمرار في الحل حتى مع انقطاع الاتصال.',
          ),
          SizedBox(height: 8.h),
          ExamRuleItem(
            title: 'الحفظ التلقائي',
            description: 'يتم حفظ كل إجابة تختارها محلياً فوراً وبشكل تلقائي.',
          ),
          SizedBox(height: 8.h),
          ExamRuleItem(
            title: 'انتهاء الوقت',
            description: 'عند انتهاء الوقت سيتم تسليم إجاباتك تلقائياً وحساب النتيجة.',
          ),
        ],
      ),
    );
  }
}
