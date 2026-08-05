import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';

class TeacherStudentsCubit extends Cubit<TeacherStudentsState> {
  final TeacherStudentsRepo _repo;

  TeacherStudentsCubit({required TeacherStudentsRepo repo})
      : _repo = repo,
        super(const TeacherStudentsState());

  @override
  void emit(TeacherStudentsState state) {
    if (isClosed) return;
    super.emit(state);
  }

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
}

enum TeacherStudentsStatus { initial, loading, loaded, error }

class TeacherStudentsState {
  final TeacherStudentsStatus status;
  final List<Map<String, dynamic>> students;
  final String? errorMessage;

  const TeacherStudentsState({
    this.status = TeacherStudentsStatus.initial,
    this.students = const [],
    this.errorMessage,
  });

  TeacherStudentsState copyWith({
    TeacherStudentsStatus? status,
    List<Map<String, dynamic>>? students,
    String? errorMessage,
  }) {
    return TeacherStudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      errorMessage: errorMessage,
    );
  }
}
