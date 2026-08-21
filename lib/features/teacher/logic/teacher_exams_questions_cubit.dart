import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';

/// Handles question CRUD for teacher exams.
class TeacherExamsQuestionsCubit extends Cubit<TeacherExamsQuestionsState> {
  final TeacherExamsRepo _repo;

  TeacherExamsQuestionsCubit({required TeacherExamsRepo repo})
      : _repo = repo,
        super(const TeacherExamsQuestionsState());

  @override
  void emit(TeacherExamsQuestionsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadQuestions(String examId) async {
    emit(state.copyWith(questionsStatus: TeacherExamsQuestionsStatus.loading));
    final result = await _repo.questions.getQuestions(examId);
    result.when(
      success: (questions) => emit(state.copyWith(
        questionsStatus: TeacherExamsQuestionsStatus.loaded,
        questions: questions,
      )),
      failure: (message, _) => emit(state.copyWith(
        questionsStatus: TeacherExamsQuestionsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> addQuestion({
    required String examId,
    required String questionType,
    required String text,
    required List<String> options,
    String? correctAnswer,
    required int points,
    String? imageUrl,
  }) async {
    emit(state.copyWith(questionsStatus: TeacherExamsQuestionsStatus.loading));
    final result = await _repo.questions.addQuestion(
      examId: examId,
      questionType: questionType,
      text: text,
      options: options,
      correctAnswer: correctAnswer,
      points: points,
      imageUrl: imageUrl,
    );
    result.when(
      success: (question) => emit(state.copyWith(
        questionsStatus: TeacherExamsQuestionsStatus.loaded,
        questions: [...state.questions, question],
      )),
      failure: (message, _) => emit(state.copyWith(
        questionsStatus: TeacherExamsQuestionsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> deleteQuestion(String questionId) async {
    final result = await _repo.questions.deleteQuestion(questionId);
    result.when(
      success: (_) => emit(state.copyWith(
        questions: state.questions.where((q) => q.id != questionId).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadExamQuestionStats(String teacherId) async {
    final result = await _repo.questions.getExamQuestionStats(teacherId);
    result.when(
      success: (stats) => emit(state.copyWith(examQuestionStats: stats)),
      failure: (_, _) {},
    );
  }
}

enum TeacherExamsQuestionsStatus { initial, loading, loaded, error }

class TeacherExamsQuestionsState {
  final TeacherExamsQuestionsStatus questionsStatus;
  final List<QuestionModel> questions;
  final Map<String, Map<String, int>> examQuestionStats;
  final String? errorMessage;

  const TeacherExamsQuestionsState({
    this.questionsStatus = TeacherExamsQuestionsStatus.initial,
    this.questions = const [],
    this.examQuestionStats = const {},
    this.errorMessage,
  });

  TeacherExamsQuestionsState copyWith({
    TeacherExamsQuestionsStatus? questionsStatus,
    List<QuestionModel>? questions,
    Map<String, Map<String, int>>? examQuestionStats,
    String? errorMessage,
  }) {
    return TeacherExamsQuestionsState(
      questionsStatus: questionsStatus ?? this.questionsStatus,
      questions: questions ?? this.questions,
      examQuestionStats: examQuestionStats ?? this.examQuestionStats,
      errorMessage: errorMessage,
    );
  }
}
