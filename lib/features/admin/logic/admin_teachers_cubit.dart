import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';

class AdminTeachersCubit extends Cubit<AdminTeachersState> {
  final AdminTeachersRepo _repo;

  AdminTeachersCubit({required AdminTeachersRepo repo})
      : _repo = repo,
        super(const AdminTeachersState());

  Future<void> loadPendingTeachers() async {
    emit(state.copyWith(status: AdminTeachersStatus.loading));
    final result = await _repo.getPendingTeachers();
    result.when(
      success: (teachers) => emit(state.copyWith(
        status: AdminTeachersStatus.loaded,
        pendingTeachers: teachers,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: AdminTeachersStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadAllTeachers() async {
    emit(state.copyWith(status: AdminTeachersStatus.loading));
    final result = await _repo.getAllTeachers();
    result.when(
      success: (teachers) => emit(state.copyWith(
        status: AdminTeachersStatus.loaded,
        allTeachers: teachers,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: AdminTeachersStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> approveTeacher(String teacherId) async {
    final result = await _repo.approveTeacher(teacherId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          pendingTeachers: state.pendingTeachers
              .where((t) => t['id'] != teacherId)
              .toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> rejectTeacher(String teacherId, String reason) async {
    final result = await _repo.rejectTeacher(teacherId, reason);
    result.when(
      success: (_) {
        emit(state.copyWith(
          pendingTeachers: state.pendingTeachers
              .where((t) => t['id'] != teacherId)
              .toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> toggleRenewalAlert(String teacherId, bool requiresRenewal) async {
    // Optimistically update allTeachers list in state
    final updated = state.allTeachers.map((t) {
      if (t['id'] == teacherId) {
        return {...t, 'requires_renewal': requiresRenewal};
      }
      return t;
    }).toList();
    emit(state.copyWith(allTeachers: updated));

    final result = await _repo.toggleRenewalAlert(teacherId, requiresRenewal);
    result.when(
      success: (_) {},
      failure: (message, _) {
        loadAllTeachers();
        emit(state.copyWith(errorMessage: message));
      },
    );
  }

  Future<void> toggleBanTeacher(String teacherId, bool isBanned, {String? reason}) async {
    final newStatus = isBanned ? 'banned' : 'approved';
    final updated = state.allTeachers.map((t) {
      if (t['id'] == teacherId) {
        return {
          ...t,
          'approval_status': newStatus,
          'rejection_reason': isBanned ? reason : null,
        };
      }
      return t;
    }).toList();
    emit(state.copyWith(allTeachers: updated));

    final result = await _repo.toggleBanTeacher(teacherId, isBanned, reason: reason);
    result.when(
      success: (_) {},
      failure: (message, _) {
        loadAllTeachers();
        emit(state.copyWith(errorMessage: message));
      },
    );
  }
}

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
