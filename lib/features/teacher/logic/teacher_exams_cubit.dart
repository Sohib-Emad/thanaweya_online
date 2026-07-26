import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';

class TeacherExamsCubit extends Cubit<TeacherExamsState> {
  final TeacherExamsRepo _repo;

  TeacherExamsCubit({required TeacherExamsRepo repo})
      : _repo = repo,
        super(const TeacherExamsState());

  Future<void> loadExams(String teacherId) async {
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.getExams(teacherId);
    result.when(
      success: (exams) => emit(state.copyWith(
        status: TeacherExamsStatus.loaded,
        exams: exams,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> createExam({
    required String teacherId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    String? courseId,
  }) async {
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.createExam(
      teacherId: teacherId,
      title: title,
      durationMinutes: durationMinutes,
      startAt: startAt,
      endAt: endAt,
      courseId: courseId,
    );
    result.when(
      success: (exam) {
        emit(state.copyWith(
          status: TeacherExamsStatus.loaded,
          exams: [exam, ...state.exams],
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> publishExam(String examId) async {
    final result = await _repo.publishExam(examId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          exams: state.exams.map((e) {
            if (e.id == examId) return e.copyWith(isPublished: true);
            return e;
          }).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> deleteExam(String examId) async {
    final result = await _repo.deleteExam(examId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          exams: state.exams.where((e) => e.id != examId).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadQuestions(String examId) async {
    emit(state.copyWith(questionsStatus: TeacherExamsStatus.loading));
    final result = await _repo.getQuestions(examId);
    result.when(
      success: (questions) => emit(state.copyWith(
        questionsStatus: TeacherExamsStatus.loaded,
        questions: questions,
      )),
      failure: (message, _) => emit(state.copyWith(
        questionsStatus: TeacherExamsStatus.error,
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
  }) async {
    emit(state.copyWith(questionsStatus: TeacherExamsStatus.loading));
    final result = await _repo.addQuestion(
      examId: examId,
      questionType: questionType,
      text: text,
      options: options,
      correctAnswer: correctAnswer,
      points: points,
    );
    result.when(
      success: (question) {
        emit(state.copyWith(
          questionsStatus: TeacherExamsStatus.loaded,
          questions: [...state.questions, question],
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        questionsStatus: TeacherExamsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> deleteQuestion(String questionId) async {
    final result = await _repo.deleteQuestion(questionId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          questions:
              state.questions.where((q) => q.id != questionId).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }
}

enum TeacherExamsStatus { initial, loading, loaded, error }

class TeacherExamsState {
  final TeacherExamsStatus status;
  final List<ExamModel> exams;
  final TeacherExamsStatus questionsStatus;
  final List<QuestionModel> questions;
  final String? errorMessage;

  const TeacherExamsState({
    this.status = TeacherExamsStatus.initial,
    this.exams = const [],
    this.questionsStatus = TeacherExamsStatus.initial,
    this.questions = const [],
    this.errorMessage,
  });

  TeacherExamsState copyWith({
    TeacherExamsStatus? status,
    List<ExamModel>? exams,
    TeacherExamsStatus? questionsStatus,
    List<QuestionModel>? questions,
    String? errorMessage,
  }) {
    return TeacherExamsState(
      status: status ?? this.status,
      exams: exams ?? this.exams,
      questionsStatus: questionsStatus ?? this.questionsStatus,
      questions: questions ?? this.questions,
      errorMessage: errorMessage,
    );
  }
}
