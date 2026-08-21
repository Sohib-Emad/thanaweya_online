import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/exam_scoring_helper.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen where students take an exam with server-authoritative timer,
/// offline support, and automatic answer persistence.
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

  /// One-second ticker — does NOT track elapsed time itself;
  /// we re-compute from [examStartedAt] on every tick so the count is
  /// always accurate even after the app wakes from background.
  Timer? _ticker;
  int _secondsRemaining = 0;
  bool _isSubmitting = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = StudentExamsCubit(repo: StudentExamsRepo());

    // When exam loads, start the ticker
    _cubit.stream.listen((state) {
      if (state.examStartedAt != null && _ticker == null) {
        _startTicker();
      }
    });

    _cubit.startExam(widget.examId);
    _watchConnectivity();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _cubit.state.computeSecondsRemaining();
      setState(() => _secondsRemaining = remaining);
      if (remaining <= 0) {
        _ticker?.cancel();
        _submitExam(isTimeOut: true);
      }
    });
    // Initial value
    setState(() => _secondsRemaining = _cubit.state.computeSecondsRemaining());
  }

  void _watchConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = !results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
      _cubit.setOffline(offline);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _connectivitySub?.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes back to foreground, re-sync the timer immediately
    if (state == AppLifecycleState.resumed) {
      final remaining = _cubit.state.computeSecondsRemaining();
      if (mounted) setState(() => _secondsRemaining = remaining);
      if (remaining <= 0) {
        _ticker?.cancel();
        _submitExam(isTimeOut: true);
      }
    }
  }

  String _formatTimer(int t) =>
      '${(t ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}';

  (int, int) _calculateScore(List<QuestionModel> questions, Map<String, String> answers) {
    int score = 0, total = 0;
    for (final q in questions) {
      total += q.points;
      final studentAns = answers[q.id];
      if (ExamScoringHelper.isCorrect(q, studentAns)) {
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
    _ticker?.cancel();
    final state = _cubit.state;
    final studentId = Supabase.instance.client.auth.currentUser?.id;
    final (score, total) = _calculateScore(state.currentQuestions, state.answers);
    if (studentId != null && widget.examId.isNotEmpty) {
      await _cubit.submitExam(examId: widget.examId, studentId: studentId);
    }
    if (!mounted) return;
    final finalScore = _cubit.state.lastScore ?? score;
    final finalTotal = _cubit.state.lastTotalPoints ?? total;
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, AppRouter.studentExamResult, arguments: {
      'score': finalScore,
      'total': finalTotal,
      'autoSubmitted': autoSubmitted,
      'isTimeOut': isTimeOut,
      'examId': widget.examId,
      'examTitle': widget.examTitle,
      'maxAttempts': widget.maxAttempts,
      'attemptNumber': widget.attemptsUsed + 1,
      'passingScore': state.currentExam?.passingScore ?? 50,
      'isPendingSync': state.pendingSyncCount > 0,
    });
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
              return _buildLoading(l10n);
            }
            if (state.examStatus == StudentExamsStatus.error ||
                state.currentQuestions.isEmpty) {
              return _buildError(state, l10n);
            }
            return ExamBody(
              state: state,
              secondsRemaining: _secondsRemaining,
              formattedTime: _formatTimer(_secondsRemaining),
              cubit: _cubit,
              onSubmit: _submitExam,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: NotebookColors.green),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الاختبار...',
            style: NotebookText.body(14),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى الانتظار حتى يكتمل التحميل',
            style: NotebookText.note(12),
          ),
        ],
      ),
    );
  }

  Widget _buildError(StudentExamsState state, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          NotebookEmptyNote(
            icon: Icons.error_outline_rounded,
            message: state.errorMessage ?? l10n.loadQuestionsError,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: NotebookPrimaryButton(
              label: l10n.backLabel,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ]),
      ),
    );
  }
}
