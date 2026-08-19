import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';
export 'package:thanaweya_online/features/student/logic/student_onboarding_state.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_state.dart';

class StudentOnboardingCubit extends Cubit<StudentOnboardingState> {
  final StudentOnboardingRepo _repo;

  StudentOnboardingCubit({required StudentOnboardingRepo repo})
      : _repo = repo,
        super(const StudentOnboardingState());

  @override
  void emit(StudentOnboardingState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

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
