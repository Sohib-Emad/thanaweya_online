enum StudentOnboardingStatus { initial, loading, loaded, error }

class StudentOnboardingState {
  final StudentOnboardingStatus status;
  final List<Map<String, dynamic>> subjects;
  final List<String> selectedSubjectIds;
  final StudentOnboardingStatus teachersStatus;
  final List<Map<String, dynamic>> teachers;
  final List<String> selectedTeacherIds;
  final StudentOnboardingStatus registrationStatus;
  final StudentOnboardingStatus activationStatus;
  final String? activationError;
  final StudentOnboardingStatus subscriptionsStatus;
  final List<Map<String, dynamic>> subscriptions;
  final String? errorMessage;

  const StudentOnboardingState({
    this.status = StudentOnboardingStatus.initial,
    this.subjects = const [],
    this.selectedSubjectIds = const [],
    this.teachersStatus = StudentOnboardingStatus.initial,
    this.teachers = const [],
    this.selectedTeacherIds = const [],
    this.registrationStatus = StudentOnboardingStatus.initial,
    this.activationStatus = StudentOnboardingStatus.initial,
    this.activationError,
    this.subscriptionsStatus = StudentOnboardingStatus.initial,
    this.subscriptions = const [],
    this.errorMessage,
  });

  StudentOnboardingState copyWith({
    StudentOnboardingStatus? status,
    List<Map<String, dynamic>>? subjects,
    List<String>? selectedSubjectIds,
    StudentOnboardingStatus? teachersStatus,
    List<Map<String, dynamic>>? teachers,
    List<String>? selectedTeacherIds,
    StudentOnboardingStatus? registrationStatus,
    StudentOnboardingStatus? activationStatus,
    String? activationError,
    StudentOnboardingStatus? subscriptionsStatus,
    List<Map<String, dynamic>>? subscriptions,
    String? errorMessage,
  }) {
    return StudentOnboardingState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      teachersStatus: teachersStatus ?? this.teachersStatus,
      teachers: teachers ?? this.teachers,
      selectedTeacherIds: selectedTeacherIds ?? this.selectedTeacherIds,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      activationStatus: activationStatus ?? this.activationStatus,
      activationError: activationError,
      subscriptionsStatus: subscriptionsStatus ?? this.subscriptionsStatus,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage: errorMessage,
    );
  }
}
