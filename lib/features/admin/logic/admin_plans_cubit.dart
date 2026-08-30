import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';

part 'admin_plans_state.dart';

class AdminPlansCubit extends Cubit<AdminPlansState> {
  final AdminPlansRepo _repo;

  AdminPlansCubit({required AdminPlansRepo repo})
      : _repo = repo,
        super(const AdminPlansState());

  Future<void> loadPlans() async {
    emit(state.copyWith(status: AdminPlansStatus.loading));
    final result = await _repo.getPlans();
    result.when(
      success: (plans) => emit(state.copyWith(status: AdminPlansStatus.loaded, plans: plans)),
      failure: (msg, _) => emit(state.copyWith(status: AdminPlansStatus.error, errorMessage: msg)),
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
    final res = await _repo.addPlan(
      name: name, billingPeriod: billingPeriod, price: price, maxStudents: maxStudents,
      maxCourses: maxCourses, storageLimitMb: storageLimitMb, displayOrder: displayOrder, isActive: isActive,
    );
    return res.when(
      success: (_) { loadPlans(); return true; },
      failure: (msg, _) { emit(state.copyWith(errorMessage: msg)); return false; },
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
    final res = await _repo.updatePlan(
      planId: planId, name: name, billingPeriod: billingPeriod, price: price,
      maxStudents: maxStudents, maxCourses: maxCourses, storageLimitMb: storageLimitMb, displayOrder: displayOrder, isActive: isActive,
    );
    return res.when(
      success: (_) { loadPlans(); return true; },
      failure: (msg, _) { emit(state.copyWith(errorMessage: msg)); return false; },
    );
  }

  Future<bool> deletePlan(String planId) async {
    final res = await _repo.deletePlan(planId);
    return res.when(
      success: (_) { loadPlans(); return true; },
      failure: (msg, _) { emit(state.copyWith(errorMessage: msg)); return false; },
    );
  }

  Future<void> togglePlanStatus(String planId, bool isActive) async {
    final updated = state.plans.map((p) => p['id'] == planId ? {...p, 'is_active': isActive} : p).toList();
    emit(state.copyWith(plans: updated));
    final res = await _repo.togglePlanStatus(planId, isActive);
    res.when(success: (_) {}, failure: (msg, _) { loadPlans(); emit(state.copyWith(errorMessage: msg)); });
  }
}
