import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';

/// Handles lesson listing and progress tracking for student courses.
class StudentCoursesLessonsCubit extends Cubit<StudentCoursesLessonsState> {
  final StudentCoursesRepo _repo;

  StudentCoursesLessonsCubit({required StudentCoursesRepo repo})
      : _repo = repo,
        super(const StudentCoursesLessonsState());

  @override
  void emit(StudentCoursesLessonsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadCourseLessons(String courseId) async {
    emit(state.copyWith(lessonsStatus: StudentCoursesLessonsStatus.loading));
    final result = await _repo.lessons.getCourseLessons(courseId);
    result.when(
      success: (lessons) => emit(state.copyWith(
        lessonsStatus: StudentCoursesLessonsStatus.loaded,
        lessons: lessons,
      )),
      failure: (message, _) => emit(state.copyWith(
        lessonsStatus: StudentCoursesLessonsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> updateProgress({
    required String studentId,
    required String lessonId,
    required int watchedSeconds,
    required bool isCompleted,
  }) async {
    final result = await _repo.lessons.updateLessonProgress(
      studentId: studentId,
      lessonId: lessonId,
      watchedSeconds: watchedSeconds,
      isCompleted: isCompleted,
    );
    result.when(
      success: (_) {
        final updated = List<LessonProgressModel>.from(state.progress);
        final idx = updated.indexWhere((p) => p.lessonId == lessonId);
        if (idx >= 0) {
          updated[idx] = updated[idx].copyWith(
            watchedSeconds: watchedSeconds,
            isCompleted: isCompleted,
          );
        } else {
          updated.add(LessonProgressModel(
            id: '',
            studentId: studentId,
            lessonId: lessonId,
            isCompleted: isCompleted,
            watchedSeconds: watchedSeconds,
            lastWatchedAt: DateTime.now(),
          ));
        }
        emit(state.copyWith(progress: updated));
      },
      failure: (_, __) {},
    );
  }

  Future<void> loadProgress(String studentId) async {
    final result = await _repo.lessons.getStudentProgress(studentId);
    result.when(
      success: (progress) => emit(state.copyWith(progress: progress)),
      failure: (_, __) {},
    );
  }
}

enum StudentCoursesLessonsStatus { initial, loading, loaded, error }

class StudentCoursesLessonsState {
  final StudentCoursesLessonsStatus lessonsStatus;
  final List<LessonModel> lessons;
  final List<LessonProgressModel> progress;
  final String? errorMessage;

  const StudentCoursesLessonsState({
    this.lessonsStatus = StudentCoursesLessonsStatus.initial,
    this.lessons = const [],
    this.progress = const [],
    this.errorMessage,
  });

  StudentCoursesLessonsState copyWith({
    StudentCoursesLessonsStatus? lessonsStatus,
    List<LessonModel>? lessons,
    List<LessonProgressModel>? progress,
    String? errorMessage,
  }) {
    return StudentCoursesLessonsState(
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lessons: lessons ?? this.lessons,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}
