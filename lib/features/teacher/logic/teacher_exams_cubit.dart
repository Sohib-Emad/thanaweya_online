import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
export 'package:thanaweya_online/features/teacher/logic/teacher_exams_state.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_state.dart';

/// Handles exam listing, creation, and updates for teachers.
class TeacherExamsCubit extends Cubit<TeacherExamsState> {
  final TeacherExamsRepo _repo;

  TeacherExamsCubit({required TeacherExamsRepo repo})
      : _repo = repo,
        super(const TeacherExamsState());

  @override
  void emit(TeacherExamsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadExams(String teacherId) async {
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.getExams(teacherId);
    result.when(
      success: (exams) => emit(state.copyWith(
        status: TeacherExamsStatus.loaded, exams: exams,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error, errorMessage: message,
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
    String? lessonId,
  }) async {
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.createExam(
      teacherId: teacherId, title: title,
      durationMinutes: durationMinutes,
      startAt: startAt, endAt: endAt,
      courseId: courseId, lessonId: lessonId,
    );
    result.when(
      success: (exam) => emit(state.copyWith(
        status: TeacherExamsStatus.loaded,
        exams: [exam, ...state.exams],
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error, errorMessage: message,
      )),
    );
  }

  Future<void> publishExam(String examId) async {
    final result = await _repo.publishExam(examId);
    result.when(
      success: (_) => emit(state.copyWith(
        exams: state.exams.map((e) =>
            e.id == examId ? e.copyWith(isPublished: true) : e).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> setExamPublished(String examId, bool isPublished) async {
    final result = await _repo.setExamPublished(examId, isPublished);
    result.when(
      success: (_) => emit(state.copyWith(
        exams: state.exams.map((e) =>
            e.id == examId ? e.copyWith(isPublished: isPublished) : e).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> updateExam({
    required String examId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    String? courseId,
    String? lessonId,
    bool? clearLesson,
    bool? isPublished,
  }) async {
    final result = await _repo.updateExam(
      examId: examId, title: title,
      durationMinutes: durationMinutes,
      startAt: startAt, endAt: endAt,
      courseId: courseId, lessonId: lessonId,
      clearLesson: clearLesson, isPublished: isPublished,
    );
    result.when(
      success: (_) => emit(state.copyWith(
        exams: state.exams.map((e) {
          if (e.id != examId) return e;
          return e.copyWith(
            title: title, durationMinutes: durationMinutes,
            startAt: startAt, endAt: endAt,
            courseId: courseId ?? e.courseId,
            isPublished: isPublished ?? e.isPublished,
          );
        }).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> deleteExam(String examId) async {
    final result = await _repo.deleteExam(examId);
    result.when(
      success: (_) => emit(state.copyWith(
        exams: state.exams.where((e) => e.id != examId).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadQuestions(String examId) async {
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.questions.getQuestions(examId);
    result.when(
      success: (questions) => emit(state.copyWith(
        status: TeacherExamsStatus.loaded, questions: questions,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error, errorMessage: message,
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
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.questions.addQuestion(
      examId: examId, questionType: questionType, text: text,
      options: options, correctAnswer: correctAnswer, points: points,
    );
    result.when(
      success: (question) => emit(state.copyWith(
        status: TeacherExamsStatus.loaded,
        questions: [question, ...state.questions],
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error, errorMessage: message,
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

  Future<void> loadExamQuestionStats(String examId) async {
    emit(state.copyWith(status: TeacherExamsStatus.loading));
    final result = await _repo.questions.getExamQuestionStats(examId);
    result.when(
      success: (stats) => emit(state.copyWith(
        status: TeacherExamsStatus.loaded, questionStats: stats,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamsStatus.error, errorMessage: message,
      )),
    );
  }
}
