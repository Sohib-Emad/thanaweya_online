import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/student/data/repos/student_reviews_repo.dart';

class StudentReviewsCubit extends Cubit<StudentReviewsState> {
  final StudentReviewsRepo _repo;

  StudentReviewsCubit({required StudentReviewsRepo repo})
      : _repo = repo,
        super(const StudentReviewsState());

  @override
  void emit(StudentReviewsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadReviews(String courseId) async {
    emit(state.copyWith(status: StudentReviewsStatus.loading));
    final result = await _repo.getReviews(courseId);
    result.when(
      success: (reviews) => emit(state.copyWith(
        status: StudentReviewsStatus.loaded,
        reviews: reviews,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentReviewsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadMyReview(String studentId, String courseId) async {
    final result = await _repo.getMyReview(studentId, courseId);
    result.when(
      success: (review) => emit(state.copyWith(
        myReview: review,
        myRating: (review?['rating'] as int?) ?? 0,
        myText: (review?['text'] as String?) ?? '',
      )),
      failure: (_, __) {},
    );
  }

  Future<bool> saveMyReview({
    required String studentId,
    required String courseId,
    required int rating,
    String? text,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repo.saveReview(
      studentId: studentId,
      courseId: courseId,
      rating: rating,
      text: text,
    );
    var saved = false;
    result.when(
      success: (_) {
        saved = true;
        emit(state.copyWith(
          isSaving: false,
          myRating: rating,
          myText: text ?? '',
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        isSaving: false,
        errorMessage: message,
      )),
    );
    return saved;
  }
}

enum StudentReviewsStatus { initial, loading, loaded, error }

class StudentReviewsState {
  final StudentReviewsStatus status;
  final List<Map<String, dynamic>> reviews;
  final Map<String, dynamic>? myReview;
  final int myRating;
  final String myText;
  final bool isSaving;
  final String? errorMessage;

  const StudentReviewsState({
    this.status = StudentReviewsStatus.initial,
    this.reviews = const [],
    this.myReview,
    this.myRating = 0,
    this.myText = '',
    this.isSaving = false,
    this.errorMessage,
  });

  StudentReviewsState copyWith({
    StudentReviewsStatus? status,
    List<Map<String, dynamic>>? reviews,
    Map<String, dynamic>? myReview,
    int? myRating,
    String? myText,
    bool? isSaving,
    String? errorMessage,
  }) {
    return StudentReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      myReview: myReview,
      myRating: myRating ?? this.myRating,
      myText: myText ?? this.myText,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
