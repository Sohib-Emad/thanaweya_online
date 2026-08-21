import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

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

class AdminStudentsCubit extends Cubit<AdminStudentsState> {
  final AdminStudentsRepo repo;

  AdminStudentsCubit({required this.repo}) : super(const AdminStudentsState());

  Future<void> loadData({String? initialTeacherId}) async {
    emit(state.copyWith(
      status: AdminStudentsStatus.loading,
      selectedTeacherId: initialTeacherId,
    ));

    final teachersRes = await repo.getTeachersForFilter();
    List<Map<String, dynamic>> teachers = [];
    teachersRes.when(
      success: (data) => teachers = data,
      failure: (_, _) {},
    );

    final studentsRes = await repo.getAllStudents(teacherId: initialTeacherId);
    studentsRes.when(
      success: (students) {
        final filtered = _applyFilters(
          students,
          initialTeacherId,
          state.selectedGrade,
          state.searchQuery,
        );
        emit(state.copyWith(
          status: AdminStudentsStatus.success,
          allStudents: students,
          filteredStudents: filtered,
          teachers: teachers,
          selectedTeacherId: initialTeacherId,
        ));
      },
      failure: (message, _) {
        emit(state.copyWith(
          status: AdminStudentsStatus.failure,
          teachers: teachers,
          errorMessage: message,
        ));
      },
    );
  }

  void selectTeacher(String? teacherId) async {
    emit(state.copyWith(
      status: AdminStudentsStatus.loading,
      selectedTeacherId: teacherId,
      clearTeacher: teacherId == null,
    ));

    final studentsRes = await repo.getAllStudents(teacherId: teacherId);
    studentsRes.when(
      success: (students) {
        final filtered = _applyFilters(
          students,
          teacherId,
          state.selectedGrade,
          state.searchQuery,
        );
        emit(state.copyWith(
          status: AdminStudentsStatus.success,
          allStudents: students,
          filteredStudents: filtered,
          selectedTeacherId: teacherId,
          clearTeacher: teacherId == null,
        ));
      },
      failure: (message, _) {
        emit(state.copyWith(
          status: AdminStudentsStatus.failure,
          errorMessage: message,
        ));
      },
    );
  }

  void selectGrade(String? grade) {
    final filtered = _applyFilters(
      state.allStudents,
      state.selectedTeacherId,
      grade,
      state.searchQuery,
    );
    emit(state.copyWith(
      selectedGrade: grade,
      clearGrade: grade == null,
      filteredStudents: filtered,
    ));
  }

  void setSearchQuery(String query) {
    final filtered = _applyFilters(
      state.allStudents,
      state.selectedTeacherId,
      state.selectedGrade,
      query,
    );
    emit(state.copyWith(
      searchQuery: query,
      filteredStudents: filtered,
    ));
  }

  Future<bool> unlockCourse({
    required String studentId,
    required String teacherId,
    required String courseId,
  }) async {
    final res = await repo.unlockCourse(
      studentId: studentId,
      teacherId: teacherId,
      courseId: courseId,
    );

    return res.when(
      success: (_) {
        // Refresh students data
        loadData(initialTeacherId: state.selectedTeacherId);
        return true;
      },
      failure: (msg, _) => false,
    );
  }

  Future<bool> lockCourse({
    required String studentId,
    required String teacherId,
    required String courseId,
  }) async {
    final res = await repo.lockCourse(
      studentId: studentId,
      teacherId: teacherId,
      courseId: courseId,
    );

    return res.when(
      success: (_) {
        // Refresh students data
        loadData(initialTeacherId: state.selectedTeacherId);
        return true;
      },
      failure: (msg, _) => false,
    );
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> students,
    String? teacherId,
    String? grade,
    String query,
  ) {
    var list = List<Map<String, dynamic>>.from(students);

    if (grade != null && grade.isNotEmpty && grade != 'all') {
      list = list.where((s) => s['grade_level'] == grade).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((s) {
        final users = s['users'] as Map<String, dynamic>? ?? {};
        final name = (users['full_name'] as String? ?? '').toLowerCase();
        final email = (users['email'] as String? ?? '').toLowerCase();
        final phone = (users['phone'] as String? ?? '').toLowerCase();
        final parentPhone = (s['parent_phone'] as String? ?? '').toLowerCase();

        return name.contains(q) ||
            email.contains(q) ||
            phone.contains(q) ||
            parentPhone.contains(q);
      }).toList();
    }

    return list;
  }
}
