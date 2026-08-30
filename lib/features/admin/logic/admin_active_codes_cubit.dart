import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';

part 'admin_active_codes_state.dart';

class AdminActiveCodesCubit extends Cubit<AdminActiveCodesState> {
  final AdminActiveCodesRepo repo;

  AdminActiveCodesCubit({required this.repo}) : super(const AdminActiveCodesState());

  Future<void> loadCodes({String? initialTeacherId}) async {
    emit(state.copyWith(status: AdminActiveCodesStatus.loading, selectedTeacherId: initialTeacherId));
    final tRes = await repo.getTeachers();
    final teachers = tRes.when(success: (d) => d, failure: (_, _) => <Map<String, dynamic>>[]);
    final courses = initialTeacherId?.isNotEmpty == true
        ? (await repo.getCourses(initialTeacherId!)).when(success: (d) => d, failure: (_, _) => <Map<String, dynamic>>[])
        : <Map<String, dynamic>>[];
    final codesRes = await repo.getActiveCodes(teacherId: initialTeacherId);
    codesRes.when(
      success: (codes) => emit(state.copyWith(
        status: AdminActiveCodesStatus.success,
        allCodes: codes,
        filteredCodes: _filter(codes, initialTeacherId, null, state.searchQuery),
        teachers: teachers,
        courses: courses,
        selectedTeacherId: initialTeacherId,
      )),
      failure: (msg, _) => emit(state.copyWith(status: AdminActiveCodesStatus.failure, teachers: teachers, errorMessage: msg)),
    );
  }

  void selectTeacher(String? teacherId) async {
    emit(state.copyWith(status: AdminActiveCodesStatus.loading, selectedTeacherId: teacherId, clearTeacher: teacherId == null, clearCourse: true));
    final courses = teacherId?.isNotEmpty == true
        ? (await repo.getCourses(teacherId!)).when(success: (d) => d, failure: (_, _) => <Map<String, dynamic>>[])
        : <Map<String, dynamic>>[];
    final codesRes = await repo.getActiveCodes(teacherId: teacherId);
    codesRes.when(
      success: (codes) => emit(state.copyWith(
        status: AdminActiveCodesStatus.success,
        allCodes: codes,
        filteredCodes: _filter(codes, teacherId, null, state.searchQuery),
        courses: courses,
        selectedTeacherId: teacherId,
        clearTeacher: teacherId == null,
        clearCourse: true,
      )),
      failure: (msg, _) => emit(state.copyWith(status: AdminActiveCodesStatus.failure, errorMessage: msg)),
    );
  }

  void selectCourse(String? cId) => emit(state.copyWith(
        selectedCourseId: cId,
        clearCourse: cId == null,
        filteredCodes: _filter(state.allCodes, state.selectedTeacherId, cId, state.searchQuery),
      ));

  void setSearchQuery(String q) => emit(state.copyWith(
        searchQuery: q,
        filteredCodes: _filter(state.allCodes, state.selectedTeacherId, state.selectedCourseId, q),
      ));

  Future<bool> generateCodes({
    required String teacherId,
    String? courseId,
    required int count,
    required double price,
  }) async {
    final res = await repo.generateCodes(
      teacherId: teacherId,
      courseId: courseId,
      count: count,
      price: price,
    );
    return res.when(
      success: (_) { loadCodes(initialTeacherId: state.selectedTeacherId); return true; },
      failure: (msg, _) { emit(state.copyWith(errorMessage: msg)); return false; },
    );
  }

  Future<bool> deleteCode(String codeId) async {
    final res = await repo.deleteCode(codeId);
    return res.when(
      success: (_) {
        final all = state.allCodes.where((c) => c['id'] != codeId).toList();
        emit(state.copyWith(allCodes: all, filteredCodes: _filter(all, state.selectedTeacherId, state.selectedCourseId, state.searchQuery)));
        return true;
      },
      failure: (_, _) => false,
    );
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> list, String? tId, String? cId, String q) {
    var res = List<Map<String, dynamic>>.from(list);
    if (tId?.isNotEmpty == true) res = res.where((c) => c['teacher_id'] == tId).toList();
    if (cId?.isNotEmpty == true) res = res.where((c) => c['course_id'] == cId).toList();
    if (q.trim().isNotEmpty) {
      final query = q.trim().toUpperCase();
      res = res.where((c) {
        final code = (c['code'] as String? ?? '').toUpperCase();
        final teacher = (((c['teachers'] as Map?)?['users'] as Map?)?['full_name'] as String? ?? '').toUpperCase();
        final course = ((c['courses'] as Map?)?['title'] as String? ?? '').toUpperCase();
        return code.contains(query) || teacher.contains(query) || course.contains(query);
      }).toList();
    }
    return res;
  }
}
