import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';

enum AdminActiveCodesStatus { initial, loading, success, failure }

class AdminActiveCodesState {
  final AdminActiveCodesStatus status;
  final List<Map<String, dynamic>> allCodes;
  final List<Map<String, dynamic>> filteredCodes;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> courses;
  final String? selectedTeacherId;
  final String? selectedCourseId;
  final String searchQuery;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const AdminActiveCodesState({
    this.status = AdminActiveCodesStatus.initial,
    this.allCodes = const [],
    this.filteredCodes = const [],
    this.teachers = const [],
    this.courses = const [],
    this.selectedTeacherId,
    this.selectedCourseId,
    this.searchQuery = '',
    this.errorMessage,
    this.actionSuccessMessage,
  });

  AdminActiveCodesState copyWith({
    AdminActiveCodesStatus? status,
    List<Map<String, dynamic>>? allCodes,
    List<Map<String, dynamic>>? filteredCodes,
    List<Map<String, dynamic>>? teachers,
    List<Map<String, dynamic>>? courses,
    String? selectedTeacherId,
    bool clearTeacher = false,
    String? selectedCourseId,
    bool clearCourse = false,
    String? searchQuery,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return AdminActiveCodesState(
      status: status ?? this.status,
      allCodes: allCodes ?? this.allCodes,
      filteredCodes: filteredCodes ?? this.filteredCodes,
      teachers: teachers ?? this.teachers,
      courses: courses ?? this.courses,
      selectedTeacherId:
          clearTeacher ? null : (selectedTeacherId ?? this.selectedTeacherId),
      selectedCourseId:
          clearCourse ? null : (selectedCourseId ?? this.selectedCourseId),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }
}

class AdminActiveCodesCubit extends Cubit<AdminActiveCodesState> {
  final AdminActiveCodesRepo repo;

  AdminActiveCodesCubit({required this.repo})
      : super(const AdminActiveCodesState());

  Future<void> loadCodes({String? initialTeacherId}) async {
    emit(state.copyWith(
      status: AdminActiveCodesStatus.loading,
      selectedTeacherId: initialTeacherId,
    ));

    final teachersRes = await repo.getTeachers();
    List<Map<String, dynamic>> teachers = [];
    teachersRes.when(
      success: (data) => teachers = data,
      failure: (_, _) {},
    );

    List<Map<String, dynamic>> courses = [];
    if (initialTeacherId != null && initialTeacherId.isNotEmpty) {
      final coursesRes = await repo.getCourses(initialTeacherId);
      coursesRes.when(
        success: (data) => courses = data,
        failure: (_, _) {},
      );
    }

    final codesRes = await repo.getActiveCodes(teacherId: initialTeacherId);
    codesRes.when(
      success: (codes) {
        final filtered = _applyFilters(
          codes,
          initialTeacherId,
          null,
          state.searchQuery,
        );
        emit(state.copyWith(
          status: AdminActiveCodesStatus.success,
          allCodes: codes,
          filteredCodes: filtered,
          teachers: teachers,
          courses: courses,
          selectedTeacherId: initialTeacherId,
        ));
      },
      failure: (message, _) {
        emit(state.copyWith(
          status: AdminActiveCodesStatus.failure,
          teachers: teachers,
          errorMessage: message,
        ));
      },
    );
  }

  void selectTeacher(String? teacherId) async {
    emit(state.copyWith(
      status: AdminActiveCodesStatus.loading,
      selectedTeacherId: teacherId,
      clearTeacher: teacherId == null,
      clearCourse: true,
    ));

    List<Map<String, dynamic>> courses = [];
    if (teacherId != null && teacherId.isNotEmpty) {
      final coursesRes = await repo.getCourses(teacherId);
      coursesRes.when(
        success: (data) => courses = data,
        failure: (_, _) {},
      );
    }

    final codesRes = await repo.getActiveCodes(teacherId: teacherId);
    codesRes.when(
      success: (codes) {
        final filtered = _applyFilters(
          codes,
          teacherId,
          null,
          state.searchQuery,
        );
        emit(state.copyWith(
          status: AdminActiveCodesStatus.success,
          allCodes: codes,
          filteredCodes: filtered,
          courses: courses,
          selectedTeacherId: teacherId,
          clearTeacher: teacherId == null,
          clearCourse: true,
        ));
      },
      failure: (message, _) {
        emit(state.copyWith(
          status: AdminActiveCodesStatus.failure,
          errorMessage: message,
        ));
      },
    );
  }

  void selectCourse(String? courseId) {
    final filtered = _applyFilters(
      state.allCodes,
      state.selectedTeacherId,
      courseId,
      state.searchQuery,
    );
    emit(state.copyWith(
      selectedCourseId: courseId,
      clearCourse: courseId == null,
      filteredCodes: filtered,
    ));
  }

  void setSearchQuery(String query) {
    final filtered = _applyFilters(
      state.allCodes,
      state.selectedTeacherId,
      state.selectedCourseId,
      query,
    );
    emit(state.copyWith(
      searchQuery: query,
      filteredCodes: filtered,
    ));
  }

  Future<bool> generateCodes({
    required String teacherId,
    String? courseId,
    required int count,
  }) async {
    final res = await repo.generateCodes(
      teacherId: teacherId,
      courseId: courseId,
      count: count,
    );

    return res.when(
      success: (inserted) {
        loadCodes(initialTeacherId: state.selectedTeacherId);
        return true;
      },
      failure: (msg, _) {
        emit(state.copyWith(errorMessage: msg));
        return false;
      },
    );
  }

  Future<bool> deleteCode(String codeId) async {
    final res = await repo.deleteCode(codeId);
    return res.when(
      success: (_) {
        final updatedAll =
            state.allCodes.where((c) => c['id'] != codeId).toList();
        final updatedFiltered = _applyFilters(
          updatedAll,
          state.selectedTeacherId,
          state.selectedCourseId,
          state.searchQuery,
        );
        emit(state.copyWith(
          allCodes: updatedAll,
          filteredCodes: updatedFiltered,
        ));
        return true;
      },
      failure: (msg, _) => false,
    );
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> codes,
    String? teacherId,
    String? courseId,
    String query,
  ) {
    var list = List<Map<String, dynamic>>.from(codes);

    if (teacherId != null && teacherId.isNotEmpty) {
      list = list.where((c) => c['teacher_id'] == teacherId).toList();
    }

    if (courseId != null && courseId.isNotEmpty) {
      list = list.where((c) => c['course_id'] == courseId).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toUpperCase();
      list = list.where((c) {
        final code = (c['code'] as String? ?? '').toUpperCase();
        final teacherName =
            (((c['teachers'] as Map<String, dynamic>?)?['users']
                        as Map<String, dynamic>?)?['full_name'] as String? ??
                    '')
                .toUpperCase();
        final courseTitle =
            ((c['courses'] as Map<String, dynamic>?)?['title'] as String? ?? '')
                .toUpperCase();

        return code.contains(q) ||
            teacherName.contains(q) ||
            courseTitle.contains(q);
      }).toList();
    }

    return list;
  }
}
