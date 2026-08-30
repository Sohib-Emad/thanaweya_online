import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_subjects_repo.dart';

part 'admin_subjects_state.dart';

class AdminSubjectsCubit extends Cubit<AdminSubjectsState> {
  final AdminSubjectsRepo _repo;

  AdminSubjectsCubit({required AdminSubjectsRepo repo})
      : _repo = repo,
        super(const AdminSubjectsState());

  Future<void> loadSubjects() async {
    emit(state.copyWith(status: AdminSubjectsStatus.loading));
    final result = await _repo.getSubjects();
    result.when(
      success: (subjects) => emit(state.copyWith(
        status: AdminSubjectsStatus.loaded,
        subjects: subjects,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: AdminSubjectsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> addSubject({
    required String nameAr,
    required String nameEn,
    String? iconName,
  }) async {
    final result = await _repo.addSubject(
      nameAr: nameAr,
      nameEn: nameEn,
      iconName: iconName,
    );
    result.when(
      success: (_) => loadSubjects(),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> updateSubject({
    required String subjectId,
    required String nameAr,
    required String nameEn,
    String? iconName,
    bool? isActive,
  }) async {
    final result = await _repo.updateSubject(
      subjectId: subjectId,
      nameAr: nameAr,
      nameEn: nameEn,
      iconName: iconName,
      isActive: isActive,
    );
    result.when(
      success: (_) => loadSubjects(),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> deleteSubject(String subjectId) async {
    final result = await _repo.deleteSubject(subjectId);
    result.when(
      success: (_) => loadSubjects(),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }
}
