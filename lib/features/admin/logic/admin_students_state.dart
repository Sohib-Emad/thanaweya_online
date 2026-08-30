part of 'admin_students_cubit.dart';

enum AdminStudentsStatus { initial, loading, success, failure }

class AdminStudentsState {
  final AdminStudentsStatus status;
  final List<Map<String, dynamic>> allStudents;
  final List<Map<String, dynamic>> filteredStudents;
  final List<Map<String, dynamic>> teachers;
  final String? selectedTeacherId;
  final String? selectedGrade;
  final String searchQuery;
  final String? errorMessage;
  final String? actionMessage;

  const AdminStudentsState({
    this.status = AdminStudentsStatus.initial,
    this.allStudents = const [],
    this.filteredStudents = const [],
    this.teachers = const [],
    this.selectedTeacherId,
    this.selectedGrade,
    this.searchQuery = '',
    this.errorMessage,
    this.actionMessage,
  });

  AdminStudentsState copyWith({
    AdminStudentsStatus? status,
    List<Map<String, dynamic>>? allStudents,
    List<Map<String, dynamic>>? filteredStudents,
    List<Map<String, dynamic>>? teachers,
    String? selectedTeacherId,
    bool clearTeacher = false,
    String? selectedGrade,
    bool clearGrade = false,
    String? searchQuery,
    String? errorMessage,
    String? actionMessage,
  }) {
    return AdminStudentsState(
      status: status ?? this.status,
      allStudents: allStudents ?? this.allStudents,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      teachers: teachers ?? this.teachers,
      selectedTeacherId:
          clearTeacher ? null : (selectedTeacherId ?? this.selectedTeacherId),
      selectedGrade:
          clearGrade ? null : (selectedGrade ?? this.selectedGrade),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }
}
