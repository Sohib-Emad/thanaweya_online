part of 'admin_teachers_cubit.dart';

enum AdminTeachersStatus { initial, loading, loaded, error }

class AdminTeachersState {
  final AdminTeachersStatus status;
  final List<Map<String, dynamic>> pendingTeachers;
  final List<Map<String, dynamic>> allTeachers;
  final String? errorMessage;

  const AdminTeachersState({
    this.status = AdminTeachersStatus.initial,
    this.pendingTeachers = const [],
    this.allTeachers = const [],
    this.errorMessage,
  });

  AdminTeachersState copyWith({
    AdminTeachersStatus? status,
    List<Map<String, dynamic>>? pendingTeachers,
    List<Map<String, dynamic>>? allTeachers,
    String? errorMessage,
  }) {
    return AdminTeachersState(
      status: status ?? this.status,
      pendingTeachers: pendingTeachers ?? this.pendingTeachers,
      allTeachers: allTeachers ?? this.allTeachers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
