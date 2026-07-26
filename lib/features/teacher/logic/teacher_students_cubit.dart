import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/activation_code_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';

class TeacherStudentsCubit extends Cubit<TeacherStudentsState> {
  final TeacherStudentsRepo _repo;

  TeacherStudentsCubit({required TeacherStudentsRepo repo})
      : _repo = repo,
        super(const TeacherStudentsState());

  Future<void> loadStudents(String teacherId) async {
    emit(state.copyWith(status: TeacherStudentsStatus.loading));
    final result = await _repo.getStudents(teacherId);
    result.when(
      success: (students) => emit(state.copyWith(
        status: TeacherStudentsStatus.loaded,
        students: students,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherStudentsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadActivationCodes(String teacherId) async {
    emit(state.copyWith(codesStatus: TeacherStudentsStatus.loading));
    final result = await _repo.getActivationCodes(teacherId);
    result.when(
      success: (codes) => emit(state.copyWith(
        codesStatus: TeacherStudentsStatus.loaded,
        activationCodes: codes,
      )),
      failure: (message, _) => emit(state.copyWith(
        codesStatus: TeacherStudentsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> generateCodes({
    required String teacherId,
    required int count,
    String? courseId,
  }) async {
    emit(state.copyWith(codesStatus: TeacherStudentsStatus.loading));
    final result = await _repo.generateCodes(
      teacherId: teacherId,
      count: count,
      courseId: courseId,
    );
    result.when(
      success: (codes) {
        emit(state.copyWith(
          codesStatus: TeacherStudentsStatus.loaded,
          activationCodes: [...codes, ...state.activationCodes],
          newCodes: codes,
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        codesStatus: TeacherStudentsStatus.error,
        errorMessage: message,
      )),
    );
  }

  void clearNewCodes() {
    emit(state.copyWith(newCodes: []));
  }
}

enum TeacherStudentsStatus { initial, loading, loaded, error }

class TeacherStudentsState {
  final TeacherStudentsStatus status;
  final List<Map<String, dynamic>> students;
  final TeacherStudentsStatus codesStatus;
  final List<ActivationCodeModel> activationCodes;
  final List<ActivationCodeModel>? newCodes;
  final String? errorMessage;

  const TeacherStudentsState({
    this.status = TeacherStudentsStatus.initial,
    this.students = const [],
    this.codesStatus = TeacherStudentsStatus.initial,
    this.activationCodes = const [],
    this.newCodes,
    this.errorMessage,
  });

  TeacherStudentsState copyWith({
    TeacherStudentsStatus? status,
    List<Map<String, dynamic>>? students,
    TeacherStudentsStatus? codesStatus,
    List<ActivationCodeModel>? activationCodes,
    List<ActivationCodeModel>? newCodes,
    String? errorMessage,
  }) {
    return TeacherStudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      codesStatus: codesStatus ?? this.codesStatus,
      activationCodes: activationCodes ?? this.activationCodes,
      newCodes: newCodes,
      errorMessage: errorMessage,
    );
  }
}
