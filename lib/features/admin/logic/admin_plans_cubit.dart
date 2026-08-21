import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';

class AdminPlansCubit extends Cubit<AdminPlansState> {
  final AdminPlansRepo _repo;

  AdminPlansCubit({required AdminPlansRepo repo})
      : _repo = repo,
        super(const AdminPlansState());

  Future<void> loadPlans() async {
    emit(state.copyWith(status: AdminPlansStatus.loading));
    final result = await _repo.getPlans();
    result.when(
      success: (plans) => emit(state.copyWith(
        status: AdminPlansStatus.loaded,
        plans: plans,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: AdminPlansStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<bool> addPlan({
    required String name,
    required String billingPeriod,
    required double price,
    int? maxStudents,
    int? maxCourses,
    int? storageLimitMb,
    int? displayOrder,
    bool isActive = true,
  }) async {
    final result = await _repo.addPlan(
      name: name,
      billingPeriod: billingPeriod,
      price: price,
      maxStudents: maxStudents,
      maxCourses: maxCourses,
      storageLimitMb: storageLimitMb,
      displayOrder: displayOrder,
      isActive: isActive,
    );
    return result.when(
      success: (_) {
        loadPlans();
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(errorMessage: message));
        return false;
      },
    );
  }

  Future<bool> updatePlan({
    required String planId,
    required String name,
    required String billingPeriod,
    required double price,
    int? maxStudents,
    int? maxCourses,
    int? storageLimitMb,
    int? displayOrder,
    bool? isActive,
  }) async {
    final result = await _repo.updatePlan(
      planId: planId,
      name: name,
      billingPeriod: billingPeriod,
      price: price,
      maxStudents: maxStudents,
      maxCourses: maxCourses,
      storageLimitMb: storageLimitMb,
      displayOrder: displayOrder,
      isActive: isActive,
    );
    return result.when(
      success: (_) {
        loadPlans();
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(errorMessage: message));
        return false;
      },
    );
  }

  Future<bool> deletePlan(String planId) async {
    final result = await _repo.deletePlan(planId);
    return result.when(
      success: (_) {
        loadPlans();
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(errorMessage: message));
        return false;
      },
    );
  }

  Future<void> togglePlanStatus(String planId, bool isActive) async {
    // Optimistic UI update
    final updatedPlans = state.plans.map((p) {
      if (p['id'] == planId) {
        return {...p, 'is_active': isActive};
      }
      return p;
    }).toList();
    emit(state.copyWith(plans: updatedPlans));

    final result = await _repo.togglePlanStatus(planId, isActive);
    result.when(
      success: (_) {},
      failure: (message, _) {
        // Rollback on failure
        loadPlans();
        emit(state.copyWith(errorMessage: message));
      },
    );
  }
}

enum AdminPlansStatus { initial, loading, loaded, error }

class AdminPlansState {
  final AdminPlansStatus status;
  final List<Map<String, dynamic>> plans;
  final String? errorMessage;

  const AdminPlansState({
    this.status = AdminPlansStatus.initial,
    this.plans = const [],
    this.errorMessage,
  });

  AdminPlansState copyWith({
    AdminPlansStatus? status,
    List<Map<String, dynamic>>? plans,
    String? errorMessage,
  }) {
    return AdminPlansState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      errorMessage: errorMessage,
    );
  }
}
