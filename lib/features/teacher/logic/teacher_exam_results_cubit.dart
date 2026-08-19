import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';

class TeacherExamResultsCubit extends Cubit<TeacherExamResultsState> {
  final TeacherExamsRepo _repo;

  TeacherExamResultsCubit({required TeacherExamsRepo repo})
      : _repo = repo,
        super(const TeacherExamResultsState());

  @override
  void emit(TeacherExamResultsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadSubmissions(String examId) async {
    emit(state.copyWith(status: TeacherExamResultsStatus.loading));
    final result = await _repo.getExamSubmissions(examId);
    result.when(
      success: (submissions) => emit(state.copyWith(
        status: TeacherExamResultsStatus.loaded,
        submissions: submissions,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherExamResultsStatus.error,
        errorMessage: message,
      )),
    );
  }

  /// Re-opens the exam for one student (deletes their attempts).
  Future<bool> resetStudentAttempts({
    required String examId,
    required String studentId,
  }) async {
    final result = await _repo.resetStudentAttempts(
      examId: examId,
      studentId: studentId,
    );
    return result.when(
      success: (_) {
        loadSubmissions(examId);
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(errorMessage: message));
        return false;
      },
    );
  }

  /// Re-opens the exam for every student (deletes all submissions).
  Future<bool> resetAllAttempts(String examId) async {
    final result = await _repo.resetAllAttempts(examId);
    return result.when(
      success: (_) {
        loadSubmissions(examId);
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(errorMessage: message));
        return false;
      },
    );
  }
}

enum TeacherExamResultsStatus { initial, loading, loaded, error }

class TeacherExamResultsState {
  final TeacherExamResultsStatus status;
  final List<Map<String, dynamic>> submissions;
  final String? errorMessage;

  const TeacherExamResultsState({
    this.status = TeacherExamResultsStatus.initial,
    this.submissions = const [],
    this.errorMessage,
  });

  TeacherExamResultsState copyWith({
    TeacherExamResultsStatus? status,
    List<Map<String, dynamic>>? submissions,
    String? errorMessage,
  }) {
    return TeacherExamResultsState(
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
      errorMessage: errorMessage,
    );
  }
}
