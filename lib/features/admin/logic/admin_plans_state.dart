part of 'admin_plans_cubit.dart';

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
