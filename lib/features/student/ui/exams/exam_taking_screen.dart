import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';

class ExamTakingScreen extends StatefulWidget {
  final String examId;

  const ExamTakingScreen({super.key, required this.examId});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen>
    with WidgetsBindingObserver {
  late final StudentExamsCubit _cubit;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _timerStarted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = StudentExamsCubit(repo: StudentExamsRepo());
    _listenForExamLoad();
    _cubit.startExam(widget.examId);
  }

  void _listenForExamLoad() {
    _cubit.stream.listen((state) {
      if (state.currentExam != null && !_timerStarted) {
        _timerStarted = true;
        _secondsRemaining = state.currentExam!.durationMinutes * 60;
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _cubit.close();
    super.dispose();
  }

  // App Lifecycle Observer: Auto-submit on app background / exit attempt
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _autoSubmitDueToExit();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _submitExam(isTimeOut: true);
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  (int score, int total) _calculateScore(
    List<QuestionModel> questions,
    Map<String, String> answers,
  ) {
    int score = 0;
    int total = 0;
    for (final q in questions) {
      total += q.points;
      if (q.correctAnswer != null && answers[q.id] == q.correctAnswer) {
        score += q.points;
      }
    }
    return (score, total);
  }

  Future<void> _submitAndGoToResult({
    required bool autoSubmitted,
    required bool isTimeOut,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _timer?.cancel();

    final state = _cubit.state;
    final studentId = Supabase.instance.client.auth.currentUser?.id;
    final (score, total) =
        _calculateScore(state.currentQuestions, state.answers);

    if (studentId != null && widget.examId.isNotEmpty) {
      await _cubit.submitExam(examId: widget.examId, studentId: studentId);
    }

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(
      context,
      AppRouter.studentExamResult,
      arguments: {
        'score': score,
        'total': total,
        'autoSubmitted': autoSubmitted,
        'isTimeOut': isTimeOut,
      },
    );
  }

  void _autoSubmitDueToExit() {
    if (_isSubmitting) return;
    _submitAndGoToResult(autoSubmitted: true, isTimeOut: false);
  }

  void _submitExam({bool isTimeOut = false}) {
    _submitAndGoToResult(autoSubmitted: false, isTimeOut: isTimeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        body: SafeArea(
          child: BlocBuilder<StudentExamsCubit, StudentExamsState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.examStatus == StudentExamsStatus.loading) {
                return Center(
                  child: CircularProgressIndicator(color: NotebookColors.green),
                );
              }
              if (state.examStatus == StudentExamsStatus.error ||
                  state.currentQuestions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NotebookEmptyNote(
                          icon: Icons.error_outline_rounded,
                          message:
                              state.errorMessage ?? 'تعذر تحميل أسئلة الامتحان',
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: 200.w,
                          child: NotebookPrimaryButton(
                            label: 'العودة',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return _buildExamBody(state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExamBody(StudentExamsState state) {
    final questions = state.currentQuestions;
    final currentIndex = state.currentQuestionIndex;
    final question = questions[currentIndex];
    final options = question.options;
    final letters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    final isEssay = question.questionType == QuestionType.essay;
    final urgent = _secondsRemaining < 300;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitWarningDialog();
      },
      child: NotebookPaper(
        child: Column(
          children: [
            // Top Strict Anti-Cheat Header Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: NotebookColors.marginRed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 15.r,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      'مراقبة أمنية: يمنع خروجك أو تصغير الشاشة لعدم التسليم التلقائي!',
                      style: NotebookText.strong(10.5.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Timer & Question Counter Bar
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timer as a red margin-note chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: urgent
                          ? NotebookColors.marginRed
                          : NotebookColors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: NotebookColors.marginRed,
                        width: 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: urgent
                              ? Colors.white
                              : NotebookColors.marginRed,
                          size: 14.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatTimer(_secondsRemaining),
                          style: NotebookText.strong(
                            13.sp,
                            color: urgent
                                ? Colors.white
                                : NotebookColors.marginRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'سؤال ${currentIndex + 1} من ${questions.length}',
                    style: NotebookText.strong(13.sp),
                  ),
                ],
              ),
            ),

            // Linear Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / questions.length,
                  minHeight: 6.h,
                  backgroundColor: NotebookColors.ink.withAlpha(22),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    NotebookColors.green,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Question Numbers Navigator Grid Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: List.generate(questions.length, (index) {
                  final isAnswered =
                      state.answers.containsKey(questions[index].id);
                  final isCurrent = index == currentIndex;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _cubit.goToQuestion(index);
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
            ),

            SizedBox(height: 16.h),

            // Question Body & Options
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Card Container
                    NotebookCard(
                      ruled: true,
                      ruledStartY: 40,
                      child: Text(
                        question.text,
                        style: NotebookText.body(15.sp).copyWith(height: 1.5),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    if (isEssay)
                      _buildEssayField(state, question.id)
                    else if (options.isNotEmpty)
                      ...List.generate(options.length, (optIndex) {
                        final optionText = options[optIndex];
                        final isSelected =
                            state.answers[question.id] == optionText;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _cubit.selectAnswer(question.id, optionText);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NotebookColors.surfaceBright
                                  : NotebookColors.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? NotebookColors.green
                                    : NotebookColors.ink.withAlpha(45),
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? NotebookColors.green
                                        : NotebookColors.surfaceBright,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? NotebookColors.green
                                          : NotebookColors.ink.withAlpha(60),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      optIndex < letters.length
                                          ? letters[optIndex]
                                          : '${optIndex + 1}',
                                      style: NotebookText.strong(
                                        13.sp,
                                        color: isSelected
                                            ? Colors.white
                                            : NotebookColors.pencil,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: NotebookText.body(
                                      13.sp,
                                      color: isSelected
                                          ? NotebookColors.ink
                                          : NotebookColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                    else
                      Padding(
                        padding: EdgeInsets.all(20.r),
                        child: Center(
                          child: Text(
                            'لا توجد إجابات متاحة لهذا السؤال',
                            style: NotebookText.note(13.sp),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons (Next, Previous, Submit)
            Container(
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
                        onPressed: () {
                          _cubit.previousQuestion();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: NotebookColors.pencil),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'السابق',
                          style: NotebookText.strong(
                            13.sp,
                            color: NotebookColors.pencil,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: currentIndex < questions.length - 1
                        ? NotebookPrimaryButton(
                            label: 'السؤال التالي',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () {
                              _cubit.nextQuestion();
                            },
                          )
                        : NotebookPrimaryButton(
                            label: 'تسليم الامتحان',
                            icon: Icons.flag_rounded,
                            onPressed: () => _submitExam(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssayField(StudentExamsState state, String questionId) {
    final value = state.answers[questionId] ?? '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: Text(
              'اكتب إجابتك هنا',
              style: NotebookText.strong(12.sp, color: NotebookColors.pencil),
            ),
          ),
          TextField(
            minLines: 4,
            maxLines: 8,
            textDirection: TextDirection.rtl,
            onChanged: (v) => _cubit.selectAnswer(questionId, v),
            decoration: InputDecoration(
              hintText: 'اكتب الإجابة بالتفصيل...',
              hintStyle: NotebookText.note(12.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
            ),
            style: NotebookText.body(13.sp).copyWith(height: 1.5),
          ),
          if (value.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
              child: Text(
                'المحفوظ: ${value.length} حرف',
                style: NotebookText.strong(
                  11.sp,
                  color: NotebookColors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
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
                  'حظر الخروج من الامتحان',
                  style: NotebookText.heading(16.sp),
                ),
              ),
            ],
          ),
          content: Text(
            'مغادرة شاشة الامتحان الآن ستؤدي إلى التسليم الفوري لكافة إجاباتك الحالية واحتساب الدرجة النهائية. هل ترغب بالتسليم والخروج؟',
            style: NotebookText.body(13.sp,
                    color: NotebookColors.pencil)
                .copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء ومتابعة الحل',
                style: NotebookText.strong(13.sp, color: NotebookColors.green),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _submitExam(); // Submit exam
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NotebookColors.marginRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'تسليم الآن',
                style: NotebookText.strong(13.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
