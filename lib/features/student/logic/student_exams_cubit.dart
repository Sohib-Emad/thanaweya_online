import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';

class StudentExamsCubit extends Cubit<StudentExamsState> {
  final StudentExamsRepo _repo;

  StudentExamsCubit({required StudentExamsRepo repo})
      : _repo = repo,
        super(const StudentExamsState());

  Future<void> loadAvailableExams(String studentId) async {
    emit(state.copyWith(status: StudentExamsStatus.loading));
    final result = await _repo.getAvailableExams(studentId);
    result.when(
      success: (exams) => emit(state.copyWith(
        status: StudentExamsStatus.loaded,
        availableExams: exams,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentExamsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> startExam(String examId) async {
    emit(state.copyWith(examStatus: StudentExamsStatus.loading));

    final examResult = await _repo.getExam(examId);
    final questionsResult = await _repo.getExamQuestions(examId);

    examResult.when(
      success: (exam) {
        questionsResult.when(
          success: (questions) => emit(state.copyWith(
            examStatus: StudentExamsStatus.loaded,
            currentExam: exam,
            currentQuestions: questions,
            answers: {},
            currentQuestionIndex: 0,
          )),
          failure: (message, _) => emit(state.copyWith(
            examStatus: StudentExamsStatus.error,
            errorMessage: message,
          )),
        );
      },
      failure: (message, _) => emit(state.copyWith(
        examStatus: StudentExamsStatus.error,
        errorMessage: message,
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
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      ));
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      ));
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
      if (state.answers[q.id] == q.correctAnswer) {
        score += q.points;
      }
    }

    final result = await _repo.submitExam(
      examId: examId,
      studentId: studentId,
      score: score,
      totalPoints: totalPoints,
      answers: state.answers,
    );

    result.when(
      success: (_) => emit(state.copyWith(
        submissionStatus: StudentExamsStatus.loaded,
        lastScore: score,
        lastTotalPoints: totalPoints,
      )),
      failure: (message, _) => emit(state.copyWith(
        submissionStatus: StudentExamsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadSubmissions(String studentId) async {
    emit(state.copyWith(submissionsStatus: StudentExamsStatus.loading));
    final result = await _repo.getStudentSubmissions(studentId);
    result.when(
      success: (submissions) => emit(state.copyWith(
        submissionsStatus: StudentExamsStatus.loaded,
        submissions: submissions,
      )),
      failure: (message, _) => emit(state.copyWith(
        submissionsStatus: StudentExamsStatus.error,
        errorMessage: message,
      )),
    );
  }
}

enum StudentExamsStatus { initial, loading, loaded, error }

class StudentExamsState {
  final StudentExamsStatus status;
  final List<Map<String, dynamic>> availableExams;
  final StudentExamsStatus examStatus;
  final ExamModel? currentExam;
  final List<QuestionModel> currentQuestions;
  final Map<String, String> answers;
  final int currentQuestionIndex;
  final StudentExamsStatus submissionStatus;
  final int? lastScore;
  final int? lastTotalPoints;
  final StudentExamsStatus submissionsStatus;
  final List<Map<String, dynamic>> submissions;
  final String? errorMessage;

  const StudentExamsState({
    this.status = StudentExamsStatus.initial,
    this.availableExams = const [],
    this.examStatus = StudentExamsStatus.initial,
    this.currentExam,
    this.currentQuestions = const [],
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.submissionStatus = StudentExamsStatus.initial,
    this.lastScore,
    this.lastTotalPoints,
    this.submissionsStatus = StudentExamsStatus.initial,
    this.submissions = const [],
    this.errorMessage,
  });

  StudentExamsState copyWith({
    StudentExamsStatus? status,
    List<Map<String, dynamic>>? availableExams,
    StudentExamsStatus? examStatus,
    ExamModel? currentExam,
    List<QuestionModel>? currentQuestions,
    Map<String, String>? answers,
    int? currentQuestionIndex,
    StudentExamsStatus? submissionStatus,
    int? lastScore,
    int? lastTotalPoints,
    StudentExamsStatus? submissionsStatus,
    List<Map<String, dynamic>>? submissions,
    String? errorMessage,
  }) {
    return StudentExamsState(
      status: status ?? this.status,
      availableExams: availableExams ?? this.availableExams,
      examStatus: examStatus ?? this.examStatus,
      currentExam: currentExam ?? this.currentExam,
      currentQuestions: currentQuestions ?? this.currentQuestions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      lastScore: lastScore ?? this.lastScore,
      lastTotalPoints: lastTotalPoints ?? this.lastTotalPoints,
      submissionsStatus: submissionsStatus ?? this.submissionsStatus,
      submissions: submissions ?? this.submissions,
      errorMessage: errorMessage,
    );
  }
}
