part of 'admin_subjects_cubit.dart';

enum AdminSubjectsStatus { initial, loading, loaded, error }

class AdminSubjectsState {
  final AdminSubjectsStatus status;
  final List<Map<String, dynamic>> subjects;
  final String? errorMessage;

  const AdminSubjectsState({
    this.status = AdminSubjectsStatus.initial,
    this.subjects = const [],
    this.errorMessage,
  });

  AdminSubjectsState copyWith({
    AdminSubjectsStatus? status,
    List<Map<String, dynamic>>? subjects,
    String? errorMessage,
  }) {
    return AdminSubjectsState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage,
    );
  }
}
