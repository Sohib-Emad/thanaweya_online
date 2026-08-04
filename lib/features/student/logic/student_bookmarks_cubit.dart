import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/student/data/repos/student_bookmarks_repo.dart';

class StudentBookmarksCubit extends Cubit<StudentBookmarksState> {
  final StudentBookmarksRepo _repo;

  StudentBookmarksCubit({required StudentBookmarksRepo repo})
      : _repo = repo,
        super(const StudentBookmarksState());

  Future<void> loadBookmarks(String studentId) async {
    emit(state.copyWith(status: StudentBookmarksStatus.loading));
    final result = await _repo.getBookmarks(studentId);
    result.when(
      success: (bookmarks) => emit(state.copyWith(
        status: StudentBookmarksStatus.loaded,
        bookmarks: bookmarks,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentBookmarksStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> checkBookmarked(String studentId, String courseId) async {
    final result = await _repo.isBookmarked(studentId, courseId);
    result.when(
      success: (isBookmarked) =>
          emit(state.copyWith(isBookmarked: isBookmarked)),
      failure: (_, __) {},
    );
  }

  Future<void> toggleBookmark(String studentId, String courseId) async {
    final current = state.isBookmarked;
    emit(state.copyWith(isBookmarked: !current, isSaving: true));
    final result = current
        ? await _repo.removeBookmark(studentId, courseId)
        : await _repo.addBookmark(studentId, courseId);
    result.when(
      success: (_) => emit(state.copyWith(
        isBookmarked: !current,
        isSaving: false,
      )),
      failure: (_, __) =>
          emit(state.copyWith(isBookmarked: current, isSaving: false)),
    );
  }
}

enum StudentBookmarksStatus { initial, loading, loaded, error }

class StudentBookmarksState {
  final StudentBookmarksStatus status;
  final List<Map<String, dynamic>> bookmarks;
  final bool isBookmarked;
  final bool isSaving;
  final String? errorMessage;

  const StudentBookmarksState({
    this.status = StudentBookmarksStatus.initial,
    this.bookmarks = const [],
    this.isBookmarked = false,
    this.isSaving = false,
    this.errorMessage,
  });

  StudentBookmarksState copyWith({
    StudentBookmarksStatus? status,
    List<Map<String, dynamic>>? bookmarks,
    bool? isBookmarked,
    bool? isSaving,
    String? errorMessage,
  }) {
    return StudentBookmarksState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
