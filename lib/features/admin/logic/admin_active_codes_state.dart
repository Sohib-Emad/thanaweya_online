part of 'admin_active_codes_cubit.dart';

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
