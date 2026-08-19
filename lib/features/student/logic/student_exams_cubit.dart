import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  Future<void> startExam(String examId) async {
    emit(state.copyWith(examStatus: StudentExamsStatus.loading));
    final examResult = await _repo.getExam(examId);
    final questionsResult = await _repo.getExamQuestions(examId);
    examResult.when(
      success: (exam) => questionsResult.when(
        success: (questions) => emit(state.copyWith(
          examStatus: StudentExamsStatus.loaded,
          currentExam: exam, currentQuestions: questions,
          answers: {}, currentQuestionIndex: 0,
        )),
        failure: (m, _) => emit(state.copyWith(
          examStatus: StudentExamsStatus.error, errorMessage: m,
        )),
      ),
      failure: (m, _) => emit(state.copyWith(
        examStatus: StudentExamsStatus.error, errorMessage: m,
      )),
    );
  }

  void selectAnswer(String questionId, String answer) {
    final answers = Map<String, String>.from(state.answers);
    answers[questionId] = answer;
    emit(state.copyWith(answers: answers));
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.currentQuestions.length - 1) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void goToQuestion(int index) {
    emit(state.copyWith(currentQuestionIndex: index));
  }

  Future<void> submitExam({
    required String examId,
    required String studentId,
  }) async {
    emit(state.copyWith(submissionStatus: StudentExamsStatus.loading));
    int score = 0;
    int totalPoints = 0;
    for (final q in state.currentQuestions) {
      totalPoints += q.points;
      if (state.answers[q.id] == q.correctAnswer) score += q.points;
    }
    final result = await _repo.submitExam(
      examId: examId, studentId: studentId,
      score: score, totalPoints: totalPoints, answers: state.answers,
    );
    result.when(
      success: (_) => emit(state.copyWith(
        submissionStatus: StudentExamsStatus.loaded,
        lastScore: score, lastTotalPoints: totalPoints,
      )),
      failure: (m, _) => emit(state.copyWith(
        submissionStatus: StudentExamsStatus.error, errorMessage: m,
      )),
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
    final result = await _repo.getExamAttempts(examId: examId, studentId: studentId);
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
