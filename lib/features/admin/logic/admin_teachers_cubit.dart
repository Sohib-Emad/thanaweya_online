import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';

part 'admin_teachers_state.dart';

class AdminTeachersCubit extends Cubit<AdminTeachersState> {
  final AdminTeachersRepo _repo;

  AdminTeachersCubit({required AdminTeachersRepo repo})
      : _repo = repo,
        super(const AdminTeachersState());

  Future<void> loadPendingTeachers() async {
    emit(state.copyWith(status: AdminTeachersStatus.loading));
    final result = await _repo.getPendingTeachers();
    result.when(
      success: (teachers) => emit(state.copyWith(status: AdminTeachersStatus.loaded, pendingTeachers: teachers)),
      failure: (msg, _) => emit(state.copyWith(status: AdminTeachersStatus.error, errorMessage: msg)),
    );
  }

  Future<void> loadAllTeachers() async {
    emit(state.copyWith(status: AdminTeachersStatus.loading));
    final result = await _repo.getAllTeachers();
    result.when(
      success: (teachers) => emit(state.copyWith(status: AdminTeachersStatus.loaded, allTeachers: teachers)),
      failure: (msg, _) => emit(state.copyWith(status: AdminTeachersStatus.error, errorMessage: msg)),
    );
  }

  Future<void> approveTeacher(String teacherId) async {
    final result = await _repo.approveTeacher(teacherId);
    result.when(
      success: (_) => emit(state.copyWith(
        pendingTeachers: state.pendingTeachers.where((t) => t['id'] != teacherId).toList(),
      )),
      failure: (msg, _) => emit(state.copyWith(errorMessage: msg)),
    );
  }

  Future<void> rejectTeacher(String teacherId, String reason) async {
    final result = await _repo.rejectTeacher(teacherId, reason);
    result.when(
      success: (_) => emit(state.copyWith(
        pendingTeachers: state.pendingTeachers.where((t) => t['id'] != teacherId).toList(),
      )),
      failure: (msg, _) => emit(state.copyWith(errorMessage: msg)),
    );
  }

  Future<void> toggleRenewalAlert(String teacherId, bool requiresRenewal) async {
    final updated = state.allTeachers.map((t) {
      if (t['id'] == teacherId) return {...t, 'requires_renewal': requiresRenewal};
      return t;
    }).toList();
    emit(state.copyWith(allTeachers: updated));

    final result = await _repo.toggleRenewalAlert(teacherId, requiresRenewal);
    result.when(
      success: (_) {},
      failure: (msg, _) {
        loadAllTeachers();
        emit(state.copyWith(errorMessage: msg));
      },
    );
  }

  Future<void> toggleBanTeacher(String teacherId, bool isBanned, {String? reason}) async {
    final newStatus = isBanned ? 'banned' : 'approved';
    final updated = state.allTeachers.map((t) {
      if (t['id'] == teacherId) {
        return {...t, 'approval_status': newStatus, 'rejection_reason': isBanned ? reason : null};
      }
      return t;
    }).toList();
    emit(state.copyWith(allTeachers: updated));

    final result = await _repo.toggleBanTeacher(teacherId, isBanned, reason: reason);
    result.when(
      success: (_) {},
      failure: (msg, _) {
        loadAllTeachers();
        emit(state.copyWith(errorMessage: msg));
      },
    );
  }
}
