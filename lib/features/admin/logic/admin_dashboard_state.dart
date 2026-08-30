part of 'admin_dashboard_cubit.dart';

enum AdminDashboardStatus { initial, loading, loaded, error }

class AdminDashboardState {
  final AdminDashboardStatus status;
  final Map<String, int> stats;
  final List<Map<String, dynamic>> recentTeachers;
  final List<Map<String, dynamic>> recentStudents;
  final String? errorMessage;

  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.stats = const {},
    this.recentTeachers = const [],
    this.recentStudents = const [],
    this.errorMessage,
  });

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    Map<String, int>? stats,
    List<Map<String, dynamic>>? recentTeachers,
    List<Map<String, dynamic>>? recentStudents,
    String? errorMessage,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentTeachers: recentTeachers ?? this.recentTeachers,
      recentStudents: recentStudents ?? this.recentStudents,
      errorMessage: errorMessage,
    );
  }
}
