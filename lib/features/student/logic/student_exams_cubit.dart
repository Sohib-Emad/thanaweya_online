import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/core/utils/exam_scoring_helper.dart';
import 'package:thanaweya_online/features/student/data/repos/exam_local_cache.dart';
import 'package:thanaweya_online/features/student/data/repos/exam_sync_service.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
export 'package:thanaweya_online/features/student/logic/student_exams_state.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_state.dart';

class StudentExamsCubit extends Cubit<StudentExamsState> {
  final StudentExamsRepo _repo;

  StudentExamsCubit({required StudentExamsRepo repo})
      : _repo = repo,
        super(const StudentExamsState());

  @override
  void emit(StudentExamsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadAvailableExams(String studentId) async {
    emit(state.copyWith(status: StudentExamsStatus.loading));
    final result = await _repo.listing.getAvailableExams(studentId);
    result.when(
      success: (exams) => emit(state.copyWith(
        status: StudentExamsStatus.loaded, availableExams: exams,
      )),
      failure: (m, _) => emit(state.copyWith(
        status: StudentExamsStatus.error, errorMessage: m,
      )),
    );
    // Expose pending sync count so UI can show badge
    final pending = await ExamLocalCache.loadPendingSubmissions();
    emit(state.copyWith(pendingSyncCount: pending.length));
  }

  /// Starts an exam session.
  ///
  /// 1. Fetches exam + questions from server (or reuses cached copy).
  /// 2. Records started_at on the server (idempotent — stores only on first call).
  /// 3. Persists session locally so it survives app restarts.
  Future<void> startExam(String examId) async {
    emit(state.copyWith(examStatus: StudentExamsStatus.loading));
    final uid = _repo.currentUserId;

    // ── Load exam & questions ──────────────────────────────────────────
    final examResult = await _repo.getExam(examId);
    final questionsResult = await _repo.getExamQuestions(examId);

    bool hasError = false;
    examResult.when(
      success: (exam) {
        questionsResult.when(
          success: (questions) {
            final shuffled = exam.shuffleQuestions
                ? (List.of(questions)..shuffle())
                : questions;
            emit(state.copyWith(
              examStatus: StudentExamsStatus.loaded,
              currentExam: exam,
              currentQuestions: shuffled,
              answers: {},
              currentQuestionIndex: 0,
            ));
          },
          failure: (m, _) {
            hasError = true;
            emit(state.copyWith(
                examStatus: StudentExamsStatus.error, errorMessage: m));
          },
        );
      },
      failure: (m, _) {
        hasError = true;
        emit(state.copyWith(
            examStatus: StudentExamsStatus.error, errorMessage: m));
      },
    );
    if (hasError || uid == null) return;

    // ── Determine startedAt (server-authoritative) ─────────────────────
    final cachedStartedAt =
        await ExamLocalCache.getStartedAt(examId: examId, studentId: uid);
    DateTime startedAt;

    if (cachedStartedAt != null) {
      // Resuming an existing session — use stored start time
      startedAt = cachedStartedAt;
      // Restore cached answers
      final session = await ExamLocalCache.loadSession(
          examId: examId, studentId: uid);
      final rawAnswers = session?['answers'];
      if (rawAnswers is Map) {
        final restoredAnswers =
            rawAnswers.cast<String, dynamic>().map((k, v) => MapEntry(k, v.toString()));
        emit(state.copyWith(answers: restoredAnswers));
      }
    } else {
      // First time — record start time
      startedAt = DateTime.now().toUtc();
      // Try to persist started_at on the server (non-blocking)
      _repo.recordExamStart(examId: examId, studentId: uid, startedAt: startedAt);
    }

    emit(state.copyWith(examStartedAt: startedAt));

    // ── Save session locally ───────────────────────────────────────────
    final currentExam = state.currentExam;
    final currentQuestions = state.currentQuestions;
    if (currentExam != null && currentQuestions.isNotEmpty) {
      await ExamLocalCache.saveSession(
        examId: examId,
        studentId: uid,
        startedAt: startedAt,
        answers: state.answers,
        questions: currentQuestions
            .map((q) => q.toJson())
            .toList(),
      );
    }
  }

  void selectAnswer(String questionId, String answer) {
    final answers = Map<String, String>.from(state.answers);
    answers[questionId] = answer;
    emit(state.copyWith(answers: answers));
    // Persist answers immediately (fire-and-forget)
    final uid = _repo.currentUserId;
    final examId = state.currentExam?.id;
    if (uid != null && examId != null) {
      ExamLocalCache.updateAnswers(
          examId: examId, studentId: uid, answers: answers);
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.currentQuestions.length - 1) {
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1));
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void goToQuestion(int index) {
    emit(state.copyWith(currentQuestionIndex: index));
  }

  void setOffline(bool value) {
    emit(state.copyWith(isOffline: value));
  }

  /// Submits the exam.
  ///
  /// If offline: stores result in pending-sync queue and returns.
  /// If online: sends directly and removes from queue.
  Future<void> submitExam({
    required String examId,
    required String studentId,
  }) async {
    emit(state.copyWith(submissionStatus: StudentExamsStatus.loading));
    int score = 0;
    int totalPoints = 0;
    for (final q in state.currentQuestions) {
      totalPoints += q.points;
      final studentAns = state.answers[q.id];
      if (ExamScoringHelper.isCorrect(q, studentAns)) {
        score += q.points;
      }
    }

    final startedAt = state.examStartedAt ?? DateTime.now().toUtc();
    final submittedAt = DateTime.now().toUtc();
    final timeSpent = submittedAt.difference(startedAt).inSeconds;
    final localId = '${examId}_${studentId}_${DateTime.now().millisecondsSinceEpoch}';

    final submissionPayload = {
      'exam_id': examId,
      'student_id': studentId,
      'score': score,
      'total_points': totalPoints,
      'answers': state.answers,
      'started_at': startedAt.toIso8601String(),
      'submitted_at': submittedAt.toIso8601String(),
      'time_spent_seconds': timeSpent,
      'local_submission_id': localId,
      'is_pending_sync': false,
    };

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final hasNetwork = connectivity.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (!hasNetwork) {
      // Queue for later sync
      submissionPayload['is_pending_sync'] = true;
      await ExamLocalCache.enqueuePendingSubmission(submissionPayload);
      await ExamLocalCache.clearSession(examId: examId, studentId: studentId);
      emit(state.copyWith(
        submissionStatus: StudentExamsStatus.loaded,
        lastScore: score,
        lastTotalPoints: totalPoints,
        pendingSyncCount: state.pendingSyncCount + 1,
      ));
      return;
    }

    // Online — send directly
    final result = await _repo.submitExam(
      examId: examId,
      studentId: studentId,
      score: score,
      totalPoints: totalPoints,
      answers: state.answers,
      startedAt: startedAt,
      submittedAt: submittedAt,
      timeSpentSeconds: timeSpent,
      localSubmissionId: localId,
    );

    await ExamLocalCache.clearSession(examId: examId, studentId: studentId);
    // Try to sync any previously pending submissions
    ExamSyncService.syncNow();

    result.when(
      success: (_) => emit(state.copyWith(
        submissionStatus: StudentExamsStatus.loaded,
        lastScore: score,
        lastTotalPoints: totalPoints,
      )),
      failure: (m, _) {
        // If server fails, store locally
        submissionPayload['is_pending_sync'] = true;
        ExamLocalCache.enqueuePendingSubmission(submissionPayload);
        emit(state.copyWith(
          submissionStatus: StudentExamsStatus.loaded,
          lastScore: score,
          lastTotalPoints: totalPoints,
        ));
      },
    );
  }

  Future<void> loadSubmissions(String studentId) async {
    emit(state.copyWith(submissionsStatus: StudentExamsStatus.loading));
    final result = await _repo.getStudentSubmissions(studentId);
    result.when(
      success: (subs) => emit(state.copyWith(
        submissionsStatus: StudentExamsStatus.loaded, submissions: subs,
      )),
      failure: (m, _) => emit(state.copyWith(
        submissionsStatus: StudentExamsStatus.error, errorMessage: m,
      )),
    );
  }

  Future<void> loadExamAttempts({
    required String examId,
    required String studentId,
  }) async {
    emit(state.copyWith(attemptsStatus: StudentExamsStatus.loading));
    final result =
        await _repo.getExamAttempts(examId: examId, studentId: studentId);
    result.when(
      success: (attempts) => emit(state.copyWith(
        attemptsStatus: StudentExamsStatus.loaded, attempts: attempts,
      )),
      failure: (m, _) => emit(state.copyWith(
        attemptsStatus: StudentExamsStatus.error, errorMessage: m,
      )),
    );
  }
}
