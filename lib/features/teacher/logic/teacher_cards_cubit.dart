import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_cards_repo.dart';

enum TeacherCardsStatus { initial, loading, loaded, error }

class TeacherCardsState {
  final TeacherCardsStatus status;
  final List<Map<String, dynamic>> codes;
  final bool isGenerating;
  final String? errorMessage;
  final String? successMessage;

  const TeacherCardsState({
    this.status = TeacherCardsStatus.initial,
    this.codes = const [],
    this.isGenerating = false,
    this.errorMessage,
    this.successMessage,
  });

  TeacherCardsState copyWith({
    TeacherCardsStatus? status,
    List<Map<String, dynamic>>? codes,
    bool? isGenerating,
    String? errorMessage,
    String? successMessage,
  }) {
    return TeacherCardsState(
      status: status ?? this.status,
      codes: codes ?? this.codes,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class TeacherCardsCubit extends Cubit<TeacherCardsState> {
  final TeacherCardsRepo _repo;

  TeacherCardsCubit({required TeacherCardsRepo repo})
      : _repo = repo,
        super(const TeacherCardsState());

  Future<void> loadCodes(String teacherId) async {
    emit(state.copyWith(status: TeacherCardsStatus.loading));
    final result = await _repo.getActivationCodes(teacherId);
    result.when(
      success: (codes) => emit(state.copyWith(
        status: TeacherCardsStatus.loaded,
        codes: codes,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCardsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<bool> generateCodes({
    required String teacherId,
    String? courseId,
    required int count,
  }) async {
    emit(state.copyWith(isGenerating: true));
    final result = await _repo.generateActivationCodes(
      teacherId: teacherId,
      courseId: courseId,
      count: count,
    );

    return result.when(
      success: (newCodes) {
        final updatedList = List<Map<String, dynamic>>.from([...newCodes, ...state.codes]);
        emit(state.copyWith(
          isGenerating: false,
          codes: updatedList,
          successMessage: 'تم توليد $count كرت تفعيل بنجاح',
        ));
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(
          isGenerating: false,
          errorMessage: message,
        ));
        return false;
      },
    );
  }

  Future<bool> deleteCode(String codeId) async {
    final result = await _repo.deleteActivationCode(codeId);
    return result.when(
      success: (_) {
        final updated = state.codes.where((c) => c['id'] != codeId).toList();
        emit(state.copyWith(
          codes: updated,
          successMessage: 'تم حذف الكرت بنجاح',
        ));
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(errorMessage: message));
        return false;
      },
    );
  }
}
