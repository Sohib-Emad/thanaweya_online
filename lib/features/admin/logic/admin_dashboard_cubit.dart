import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_dashboard_repo.dart';


class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminDashboardRepo _repo;

  AdminDashboardCubit({required AdminDashboardRepo repo})
      : _repo = repo,
        super(const AdminDashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: AdminDashboardStatus.loading));

    final statsResult = await _repo.getDashboardStats();
    final teachersResult = await _repo.getRecentTeachers();
    final studentsResult = await _repo.getRecentStudents();

    statsResult.when(
      success: (stats) => emit(state.copyWith(
        status: AdminDashboardStatus.loaded,
        stats: stats,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: AdminDashboardStatus.error,
        errorMessage: message,
      )),
    );

    teachersResult.when(
      success: (teachers) => emit(state.copyWith(recentTeachers: teachers)),
      failure: (_, __) {},
    );

    studentsResult.when(
      success: (students) => emit(state.copyWith(recentStudents: students)),
      failure: (_, __) {},
    );
  }
}

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
