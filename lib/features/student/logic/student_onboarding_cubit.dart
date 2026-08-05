import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';


class StudentOnboardingCubit extends Cubit<StudentOnboardingState> {
  final StudentOnboardingRepo _repo;

  StudentOnboardingCubit({required StudentOnboardingRepo repo})
      : _repo = repo,
        super(const StudentOnboardingState());

  Future<void> loadSubjects() async {
    emit(state.copyWith(status: StudentOnboardingStatus.loading));
    final result = await _repo.getSubjects();
    result.when(
      success: (subjects) => emit(state.copyWith(
        status: StudentOnboardingStatus.loaded,
        subjects: subjects,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentOnboardingStatus.error,
        errorMessage: message,
      )),
    );
  }

  void selectSubject(String subjectId) {
    final selected = List<String>.from(state.selectedSubjectIds);
    if (selected.contains(subjectId)) {
      selected.remove(subjectId);
    } else {
      selected.add(subjectId);
    }
    emit(state.copyWith(selectedSubjectIds: selected));
  }

  Future<void> loadTeachers() async {
    emit(state.copyWith(teachersStatus: StudentOnboardingStatus.loading));
    final result = await _repo.getTeachers();
    result.when(
      success: (teachers) => emit(state.copyWith(
        teachersStatus: StudentOnboardingStatus.loaded,
        teachers: teachers,
      )),
      failure: (message, _) => emit(state.copyWith(
        teachersStatus: StudentOnboardingStatus.error,
        errorMessage: message,
      )),
    );
  }

  void selectTeacher(String teacherId) {
    final selected = List<String>.from(state.selectedTeacherIds);
    if (selected.contains(teacherId)) {
      selected.remove(teacherId);
    } else {
      selected.add(teacherId);
    }
    emit(state.copyWith(selectedTeacherIds: selected));
  }

  Future<void> registerStudent({
    required String userId,
    required String gradeLevel,
    required String parentPhone,
  }) async {
    emit(state.copyWith(registrationStatus: StudentOnboardingStatus.loading));
    final result = await _repo.registerStudent(
      userId: userId,
      gradeLevel: gradeLevel,
      parentPhone: parentPhone,
    );
    result.when(
      success: (_) => emit(state.copyWith(
        registrationStatus: StudentOnboardingStatus.loaded,
      )),
      failure: (message, _) => emit(state.copyWith(
        registrationStatus: StudentOnboardingStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadSubscriptions(String studentId) async {
    emit(state.copyWith(subscriptionsStatus: StudentOnboardingStatus.loading));
    final result = await _repo.getSubscriptions(studentId);
    result.when(
      success: (subs) => emit(state.copyWith(
        subscriptionsStatus: StudentOnboardingStatus.loaded,
        subscriptions: subs,
      )),
      failure: (message, _) => emit(state.copyWith(
        subscriptionsStatus: StudentOnboardingStatus.error,
        errorMessage: message,
      )),
    );
  }
}

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
