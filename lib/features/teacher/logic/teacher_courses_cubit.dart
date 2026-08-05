import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';

class TeacherCoursesCubit extends Cubit<TeacherCoursesState> {
  final TeacherCoursesRepo _repo;

  TeacherCoursesCubit({required TeacherCoursesRepo repo})
      : _repo = repo,
        super(const TeacherCoursesState());

  @override
  void emit(TeacherCoursesState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadCourses(String teacherId) async {
    emit(state.copyWith(status: TeacherCoursesStatus.loading));
    final result = await _repo.getCourses(teacherId);
    result.when(
      success: (courses) => emit(state.copyWith(
        status: TeacherCoursesStatus.loaded,
        courses: courses,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> createCourse({
    required String teacherId,
    required String title,
    String? description,
    String? coverImageUrl,
    bool isPublished = false,
  }) async {
    emit(state.copyWith(status: TeacherCoursesStatus.loading));
    final result = await _repo.createCourse(
      teacherId: teacherId,
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
      isPublished: isPublished,
    );
    result.when(
      success: (course) {
        emit(state.copyWith(
          status: TeacherCoursesStatus.loaded,
          courses: [...state.courses, course],
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final result = await _repo.deleteCourse(courseId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          courses: state.courses.where((c) => c.id != courseId).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadLessons(String courseId) async {
    emit(state.copyWith(lessonsStatus: TeacherCoursesStatus.loading));
    final result = await _repo.getLessons(courseId);
    result.when(
      success: (lessons) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesStatus.loaded,
        lessons: lessons,
      )),
      failure: (message, _) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesStatus.error,
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
    emit(state.copyWith(lessonsStatus: TeacherCoursesStatus.loading));
    final result = await _repo.addLesson(
      courseId: courseId,
      title: title,
      description: description,
      videoSourceType: videoSourceType,
      videoUrlOrId: videoUrlOrId,
      isFreePreview: isFreePreview,
    );
    result.when(
      success: (lesson) {
        emit(state.copyWith(
          lessonsStatus: TeacherCoursesStatus.loaded,
          lessons: [...state.lessons, lesson],
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        lessonsStatus: TeacherCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> deleteLesson(String lessonId) async {
    final result = await _repo.deleteLesson(lessonId);
    result.when(
      success: (_) {
        emit(state.copyWith(
          lessons: state.lessons.where((l) => l.id != lessonId).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> updateCourse({
    required String courseId,
    required String title,
    String? description,
    String? coverImageUrl,
    bool? isPublished,
  }) async {
    final result = await _repo.updateCourse(
      courseId: courseId,
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
      isPublished: isPublished,
    );
    result.when(
      success: (_) {
        emit(state.copyWith(
          courses: state.courses.map((c) {
            if (c.id != courseId) return c;
            return c.copyWith(
              title: title,
              description: description,
              coverImageUrl: coverImageUrl ?? c.coverImageUrl,
              isPublished: isPublished ?? c.isPublished,
            );
          }).toList(),
        ));
      },
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
    final result = await _repo.updateLesson(
      lessonId: lessonId,
      title: title,
      description: description,
      videoUrlOrId: videoUrlOrId,
      isFreePreview: isFreePreview,
    );
    result.when(
      success: (_) {
        emit(state.copyWith(
          lessons: state.lessons.map((l) {
            if (l.id != lessonId) return l;
            return l.copyWith(
              title: title,
              description: description,
              videoUrlOrId: videoUrlOrId ?? l.videoUrlOrId,
              isFreePreview: isFreePreview ?? l.isFreePreview,
            );
          }).toList(),
        ));
      },
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadCourseLessonCounts(String teacherId) async {
    final result = await _repo.getCourseLessonCounts(teacherId);
    result.when(
      success: (counts) =>
          emit(state.copyWith(courseLessonCounts: counts)),
      failure: (_, _) {},
    );
  }
}

enum TeacherCoursesStatus { initial, loading, loaded, error }

class TeacherCoursesState {
  final TeacherCoursesStatus status;
  final List<CourseModel> courses;
  final TeacherCoursesStatus lessonsStatus;
  final List<LessonModel> lessons;
  final Map<String, int> courseLessonCounts;
  final String? errorMessage;

  const TeacherCoursesState({
    this.status = TeacherCoursesStatus.initial,
    this.courses = const [],
    this.lessonsStatus = TeacherCoursesStatus.initial,
    this.lessons = const [],
    this.courseLessonCounts = const {},
    this.errorMessage,
  });

  TeacherCoursesState copyWith({
    TeacherCoursesStatus? status,
    List<CourseModel>? courses,
    TeacherCoursesStatus? lessonsStatus,
    List<LessonModel>? lessons,
    Map<String, int>? courseLessonCounts,
    String? errorMessage,
  }) {
    return TeacherCoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lessons: lessons ?? this.lessons,
      courseLessonCounts: courseLessonCounts ?? this.courseLessonCounts,
      errorMessage: errorMessage,
    );
  }
}
