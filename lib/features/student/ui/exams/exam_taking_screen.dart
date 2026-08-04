import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
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

  // App Lifecycle Observer: Auto-submit on app background / exit attempt (User Requirement)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // Auto submit exam because student exited the screen/app!
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
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: BlocBuilder<StudentExamsCubit, StudentExamsState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.examStatus == StudentExamsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.examStatus == StudentExamsStatus.error ||
                  state.currentQuestions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: const Color(0xFFE11D48),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        state.errorMessage ?? 'تعذر تحميل أسئلة الامتحان',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                        child: Text(
                          'العودة',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

    return PopScope(
      canPop: false, // Prevent back swipe / button without warning
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitWarningDialog();
      },
      child: Column(
        children: [
          // Top Strict Anti-Cheat Header Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: const Color(0xFFE11D48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 16.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  '🚨 مراقبة أمنية: يمنع خروجك أو تصغير الشاشة لعدم التسليم التلقائي!',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: _secondsRemaining < 300
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF2563EB),
                      size: 20.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _formatTimer(_secondsRemaining),
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: _secondsRemaining < 300
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                Text(
                  'سؤال ${currentIndex + 1} من ${questions.length}',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
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
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2563EB),
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
                final isAnswered = state.answers.containsKey(questions[index].id);
                final isCurrent = index == currentIndex;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _cubit.goToQuestion(index);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w),
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF2563EB)
                          : isAnswered
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF2563EB)
                            : isAnswered
                                ? const Color(0xFF0FA37F)
                                : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: isCurrent
                              ? Colors.white
                              : isAnswered
                                  ? const Color(0xFF0FA37F)
                                  : const Color(0xFF64748B),
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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      question.text,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  if (isEssay)
                    _buildEssayField(state, question.id)
                  else if (options.isNotEmpty)
                    ...List.generate(options.length, (optIndex) {
                      final optionText = options[optIndex];
                      final isSelected = state.answers[question.id] == optionText;

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
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32.r,
                                height: 32.r,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    optIndex < letters.length
                                        ? letters[optIndex]
                                        : '${optIndex + 1}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF0F172A),
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
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons (Next, Previous, Submit)
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
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
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'السابق',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: currentIndex < questions.length - 1
                      ? ElevatedButton(
                          onPressed: () {
                            _cubit.nextQuestion();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'السؤال التالي',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _submitExam(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0FA37F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'تسليم الامتحان 🏁',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEssayField(StudentExamsState state, String questionId) {
    final value = state.answers[questionId] ?? '';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اكتب إجابتك هنا 📝',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            minLines: 4,
            maxLines: 8,
            textDirection: TextDirection.rtl,
            onChanged: (v) => _cubit.selectAnswer(questionId, v),
            decoration: InputDecoration(
              hintText: 'اكتب الإجابة بالتفصيل...',
              hintStyle: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: EdgeInsets.all(14.r),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: const Color(0xFF0F172A),
              height: 1.5,
            ),
          ),
          if (value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'المحفوظ: ${value.length} حرف',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: const Color(0xFF0FA37F),
                  fontWeight: FontWeight.w700,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.report_problem_rounded, color: const Color(0xFFE11D48), size: 26.r),
              SizedBox(width: 8.w),
              Text(
                'حظر الخروج من الامتحان',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'مغادرة شاشة الامتحان الآن ستؤدي إلى التسليم الفوري لكافة إجاباتك الحالية واحتساب الدرجة النهائية. هل ترغب بالتسليم والخروج؟',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء ومتابعة الحل',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _submitExam(); // Submit exam
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'تسليم الآن',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
