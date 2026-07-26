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

  Future<void> addPlan({
    required String name,
    required String billingPeriod,
    required double price,
    int? maxStudents,
    int? maxCourses,
    int? storageLimitMb,
  }) async {
    final result = await _repo.addPlan(
      name: name,
      billingPeriod: billingPeriod,
      price: price,
      maxStudents: maxStudents,
      maxCourses: maxCourses,
      storageLimitMb: storageLimitMb,
    );
    result.when(
      success: (_) => loadPlans(),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> updatePlan({
    required String planId,
    required String name,
    required String billingPeriod,
    required double price,
    bool? isActive,
  }) async {
    final result = await _repo.updatePlan(
      planId: planId,
      name: name,
      billingPeriod: billingPeriod,
      price: price,
      isActive: isActive,
    );
    result.when(
      success: (_) => loadPlans(),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> togglePlanStatus(String planId, bool isActive) async {
    final result = await _repo.togglePlanStatus(planId, isActive);
    result.when(
      success: (_) => loadPlans(),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
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
