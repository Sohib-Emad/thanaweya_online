import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:thanaweya_online/features/student/data/repos/student_comments_repo.dart';

class StudentCommentsCubit extends Cubit<StudentCommentsState> {
  final StudentCommentsRepo _repo;

  StudentCommentsCubit({required StudentCommentsRepo repo})
      : _repo = repo,
        super(const StudentCommentsState());

  @override
  void emit(StudentCommentsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadComments(String lessonId) async {
    emit(state.copyWith(status: StudentCommentsStatus.loading));
    final result = await _repo.getComments(lessonId);
    result.when(
      success: (comments) => emit(state.copyWith(
        status: StudentCommentsStatus.loaded,
        comments: comments,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentCommentsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> addComment({
    required String lessonId,
    required String authorId,
    required String text,
  }) async {
    final result = await _repo.addComment(
      lessonId: lessonId,
      authorId: authorId,
      text: text,
    );
    result.when(
      success: (comment) {
        emit(state.copyWith(
          comments: [
            ...state.comments,
            {
              'id': comment.id,
              'lesson_id': comment.lessonId,
              'author_id': comment.authorId,
              'text': comment.text,
              'created_at': comment.createdAt.toIso8601String(),
              'users': {'full_name': ''},
            }
          ],
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> deleteComment(String commentId) async {
    final result = await _repo.deleteComment(commentId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          comments:
              state.comments.where((c) => c['id'] != commentId).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }
}

enum StudentCommentsStatus { initial, loading, loaded, error }

class StudentCommentsState {
  final StudentCommentsStatus status;
  final List<Map<String, dynamic>> comments;
  final String? errorMessage;

  const StudentCommentsState({
    this.status = StudentCommentsStatus.initial,
    this.comments = const [],
    this.errorMessage,
  });

  StudentCommentsState copyWith({
    StudentCommentsStatus? status,
    List<Map<String, dynamic>>? comments,
    String? errorMessage,
  }) {
    return StudentCommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
    );
  }
}
