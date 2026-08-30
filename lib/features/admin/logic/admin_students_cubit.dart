import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

part 'admin_students_state.dart';

class AdminStudentsCubit extends Cubit<AdminStudentsState> {
  final AdminStudentsRepo repo;

  AdminStudentsCubit({required this.repo}) : super(const AdminStudentsState());

  Future<void> loadData({String? initialTeacherId}) async {
    emit(state.copyWith(status: AdminStudentsStatus.loading, selectedTeacherId: initialTeacherId));
    final tRes = await repo.getTeachersForFilter();
    final teachers = tRes.when(success: (d) => d, failure: (_, __) => <Map<String, dynamic>>[]);
    final sRes = await repo.getAllStudents(teacherId: initialTeacherId);
    sRes.when(
      success: (students) => emit(state.copyWith(
        status: AdminStudentsStatus.success,
        allStudents: students,
        filteredStudents: _filter(students, initialTeacherId, state.selectedGrade, state.searchQuery),
        teachers: teachers,
        selectedTeacherId: initialTeacherId,
      )),
      failure: (msg, _) => emit(state.copyWith(status: AdminStudentsStatus.failure, teachers: teachers, errorMessage: msg)),
    );
  }

  void selectTeacher(String? teacherId) async {
    emit(state.copyWith(status: AdminStudentsStatus.loading, selectedTeacherId: teacherId, clearTeacher: teacherId == null));
    final sRes = await repo.getAllStudents(teacherId: teacherId);
    sRes.when(
      success: (students) => emit(state.copyWith(
        status: AdminStudentsStatus.success,
        allStudents: students,
        filteredStudents: _filter(students, teacherId, state.selectedGrade, state.searchQuery),
        selectedTeacherId: teacherId,
        clearTeacher: teacherId == null,
      )),
      failure: (msg, _) => emit(state.copyWith(status: AdminStudentsStatus.failure, errorMessage: msg)),
    );
  }

  void selectGrade(String? grade) => emit(state.copyWith(
        selectedGrade: grade,
        clearGrade: grade == null,
        filteredStudents: _filter(state.allStudents, state.selectedTeacherId, grade, state.searchQuery),
      ));

  void setSearchQuery(String query) => emit(state.copyWith(
        searchQuery: query,
        filteredStudents: _filter(state.allStudents, state.selectedTeacherId, state.selectedGrade, query),
      ));

  Future<bool> unlockCourse({required String studentId, required String teacherId, required String courseId}) async {
    final res = await repo.unlockCourse(studentId: studentId, teacherId: teacherId, courseId: courseId);
    return res.when(
      success: (_) {
        loadData(initialTeacherId: state.selectedTeacherId);
        return true;
      },
      failure: (_, __) => false,
    );
  }

  Future<bool> lockCourse({required String studentId, required String teacherId, required String courseId}) async {
    final res = await repo.lockCourse(studentId: studentId, teacherId: teacherId, courseId: courseId);
    return res.when(
      success: (_) {
        loadData(initialTeacherId: state.selectedTeacherId);
        return true;
      },
      failure: (_, __) => false,
    );
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> students, String? tId, String? grade, String query) {
    var list = List<Map<String, dynamic>>.from(students);
    if (grade?.isNotEmpty == true && grade != 'all') list = list.where((s) => s['grade_level'] == grade).toList();
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((s) {
        final users = s['users'] as Map<String, dynamic>? ?? {};
        final name = (users['full_name'] as String? ?? '').toLowerCase();
        final email = (users['email'] as String? ?? '').toLowerCase();
        final phone = (users['phone'] as String? ?? '').toLowerCase();
        final pPhone = (s['parent_phone'] as String? ?? '').toLowerCase();
        return name.contains(q) || email.contains(q) || phone.contains(q) || pPhone.contains(q);
      }).toList();
    }
    return list;
  }
}
