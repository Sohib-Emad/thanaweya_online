import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';

/// Handles lesson CRUD for teacher courses.
class TeacherCoursesLessonsCubit extends Cubit<TeacherCoursesLessonsState> {
  final TeacherCoursesRepo _repo;

  TeacherCoursesLessonsCubit({required TeacherCoursesRepo repo})
      : _repo = repo,
        super(const TeacherCoursesLessonsState());

  @override
  void emit(TeacherCoursesLessonsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadLessons(String courseId) async {
    emit(state.copyWith(lessonsStatus: TeacherCoursesLessonsStatus.loading));
    final result = await _repo.lessonsRepo.getLessons(courseId);
    result.when(
      success: (lessons) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesLessonsStatus.loaded,
        lessons: lessons,
      )),
      failure: (message, _) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesLessonsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> addLesson({
    required String courseId,
    required String title,
    String? description,
    required String videoSourceType,
    required String videoUrlOrId,
    bool isFreePreview = false,
  }) async {
    emit(state.copyWith(lessonsStatus: TeacherCoursesLessonsStatus.loading));
    final result = await _repo.lessonsRepo.addLesson(
      courseId: courseId,
      title: title,
      description: description,
      videoSourceType: videoSourceType,
      videoUrlOrId: videoUrlOrId,
      isFreePreview: isFreePreview,
    );
    result.when(
      success: (lesson) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesLessonsStatus.loaded,
        lessons: [...state.lessons, lesson],
      )),
      failure: (message, _) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesLessonsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> deleteLesson(String lessonId) async {
    final result = await _repo.lessonsRepo.deleteLesson(lessonId);
    result.when(
      success: (_) => emit(state.copyWith(
        lessons: state.lessons.where((l) => l.id != lessonId).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> updateLesson({
    required String lessonId,
    required String title,
    String? description,
    String? videoUrlOrId,
    bool? isFreePreview,
  }) async {
    final result = await _repo.lessonsRepo.updateLesson(
      lessonId: lessonId,
      title: title,
      description: description,
      videoUrlOrId: videoUrlOrId,
      isFreePreview: isFreePreview,
    );
    result.when(
      success: (_) => emit(state.copyWith(
        lessons: state.lessons.map((l) {
          if (l.id != lessonId) return l;
          return l.copyWith(
            title: title,
            description: description,
            videoUrlOrId: videoUrlOrId ?? l.videoUrlOrId,
            isFreePreview: isFreePreview ?? l.isFreePreview,
          );
        }).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadCourseLessonCounts(String teacherId) async {
    final result = await _repo.lessonsRepo.getCourseLessonCounts(teacherId);
    result.when(
      success: (counts) => emit(state.copyWith(courseLessonCounts: counts)),
      failure: (_, _) {},
    );
  }
}

enum TeacherCoursesLessonsStatus { initial, loading, loaded, error }

class TeacherCoursesLessonsState {
  final TeacherCoursesLessonsStatus lessonsStatus;
  final List<LessonModel> lessons;
  final Map<String, int> courseLessonCounts;
  final String? errorMessage;

  const TeacherCoursesLessonsState({
    this.lessonsStatus = TeacherCoursesLessonsStatus.initial,
    this.lessons = const [],
    this.courseLessonCounts = const {},
    this.errorMessage,
  });

  TeacherCoursesLessonsState copyWith({
    TeacherCoursesLessonsStatus? lessonsStatus,
    List<LessonModel>? lessons,
    Map<String, int>? courseLessonCounts,
    String? errorMessage,
  }) {
    return TeacherCoursesLessonsState(
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lessons: lessons ?? this.lessons,
      courseLessonCounts: courseLessonCounts ?? this.courseLessonCounts,
      errorMessage: errorMessage,
    );
  }
}
