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
import 'package:thanaweya_online/features/student/ui/exams/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen where students take an exam with timer, questions, and anti-cheat.
class ExamTakingScreen extends StatefulWidget {
  final String examId;
  final String examTitle;
  final int maxAttempts;
  final int attemptsUsed;
  const ExamTakingScreen({
    super.key, required this.examId, this.examTitle = '',
    this.maxAttempts = 3, this.attemptsUsed = 0,
  });
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
    _cubit.stream.listen((state) {
      if (state.currentExam != null && !_timerStarted) {
        _timerStarted = true;
        _secondsRemaining = state.currentExam!.durationMinutes * 60;
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (_secondsRemaining > 0) {
            setState(() => _secondsRemaining--);
          } else {
            _timer?.cancel();
            _submitExam(isTimeOut: true);
          }
        });
      }
    });
    _cubit.startExam(widget.examId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _autoSubmitDueToExit();
    }
  }

  String _formatTimer(int t) =>
      '${(t ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}';

  (int, int) _calculateScore(List<QuestionModel> questions, Map<String, String> answers) {
    int score = 0, total = 0;
    for (final q in questions) {
      total += q.points;
      if (q.correctAnswer != null && answers[q.id] == q.correctAnswer) score += q.points;
    }
    return (score, total);
  }

  Future<void> _submitAndGoToResult({required bool autoSubmitted, required bool isTimeOut}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _timer?.cancel();
    final state = _cubit.state;
    final studentId = Supabase.instance.client.auth.currentUser?.id;
    final (score, total) = _calculateScore(state.currentQuestions, state.answers);
    if (studentId != null && widget.examId.isNotEmpty) {
      await _cubit.submitExam(examId: widget.examId, studentId: studentId);
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, AppRouter.studentExamResult, arguments: {
      'score': score, 'total': total, 'autoSubmitted': autoSubmitted,
      'isTimeOut': isTimeOut, 'examId': widget.examId,
      'examTitle': widget.examTitle, 'maxAttempts': widget.maxAttempts,
      'attemptNumber': widget.attemptsUsed + 1,
    });
  }

  void _autoSubmitDueToExit() {
    if (_isSubmitting) return;
    _submitAndGoToResult(autoSubmitted: true, isTimeOut: false);
  }

  void _submitExam({bool isTimeOut = false}) =>
      _submitAndGoToResult(autoSubmitted: false, isTimeOut: isTimeOut);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      body: SafeArea(
        child: BlocBuilder<StudentExamsCubit, StudentExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.examStatus == StudentExamsStatus.loading) {
              return Center(child: CircularProgressIndicator(color: NotebookColors.green));
            }
            if (state.examStatus == StudentExamsStatus.error || state.currentQuestions.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    NotebookEmptyNote(icon: Icons.error_outline_rounded,
                        message: state.errorMessage ?? l10n.loadQuestionsError),
                    SizedBox(height: 16.h),
                    SizedBox(width: 200.w, child: NotebookPrimaryButton(
                        label: l10n.backLabel, onPressed: () => Navigator.pop(context))),
                  ]),
                ),
              );
            }
            return ExamBody(state: state, secondsRemaining: _secondsRemaining,
                formattedTime: _formatTimer(_secondsRemaining),
                cubit: _cubit, onSubmit: _submitExam);
          },
        ),
      ),
    );
  }
}
