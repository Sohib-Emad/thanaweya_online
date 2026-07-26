import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/user_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_profile_repo.dart';

class TeacherProfileCubit extends Cubit<TeacherProfileState> {
  final TeacherProfileRepo _repo;

  TeacherProfileCubit({required TeacherProfileRepo repo})
      : _repo = repo,
        super(const TeacherProfileState());

  Future<void> loadProfile(String userId) async {
    emit(state.copyWith(status: TeacherProfileStatus.loading));

    final userResult = await _repo.getUserProfile(userId);
    final teacherResult = await _repo.getTeacherProfile(userId);

    userResult.when(
      success: (user) {
        teacherResult.when(
          success: (teacher) {
            emit(state.copyWith(
              status: TeacherProfileStatus.loaded,
              user: user,
              teacher: teacher,
            ));
          },
          failure: (message, _) {
            emit(state.copyWith(
              status: TeacherProfileStatus.loaded,
              user: user,
            ));
          },
        );
      },
      failure: (message, _) {
        emit(state.copyWith(
          status: TeacherProfileStatus.error,
          errorMessage: message,
        ));
      },
    );
  }

  Future<void> loadStats(String userId) async {
    final students = await _repo.getStudentsCount(userId);
    final courses = await _repo.getCoursesCount(userId);
    final exams = await _repo.getExamsCount(userId);

    students.when(
      success: (count) => emit(state.copyWith(studentsCount: count)),
      failure: (_, __) {},
    );
    courses.when(
      success: (count) => emit(state.copyWith(coursesCount: count)),
      failure: (_, __) {},
    );
    exams.when(
      success: (count) => emit(state.copyWith(examsCount: count)),
      failure: (_, __) {},
    );
  }
}

enum TeacherProfileStatus { initial, loading, loaded, error }

class TeacherProfileState {
  final TeacherProfileStatus status;
  final UserModel? user;
  final dynamic teacher;
  final String? errorMessage;
  final int studentsCount;
  final int coursesCount;
  final int examsCount;

  const TeacherProfileState({
    this.status = TeacherProfileStatus.initial,
    this.user,
    this.teacher,
    this.errorMessage,
    this.studentsCount = 0,
    this.coursesCount = 0,
    this.examsCount = 0,
  });

  TeacherProfileState copyWith({
    TeacherProfileStatus? status,
    UserModel? user,
    dynamic teacher,
    String? errorMessage,
    int? studentsCount,
    int? coursesCount,
    int? examsCount,
  }) {
    return TeacherProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      teacher: teacher ?? this.teacher,
      errorMessage: errorMessage,
      studentsCount: studentsCount ?? this.studentsCount,
      coursesCount: coursesCount ?? this.coursesCount,
      examsCount: examsCount ?? this.examsCount,
    );
  }
}
