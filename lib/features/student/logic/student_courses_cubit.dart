import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';

class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  final StudentCoursesRepo _repo;

  StudentCoursesCubit({required StudentCoursesRepo repo})
      : _repo = repo,
        super(const StudentCoursesState());

  Future<void> loadSubscribedTeachers(String studentId) async {
    emit(state.copyWith(status: StudentCoursesStatus.loading));
    final result = await _repo.getSubscribedTeachers(studentId);
    result.when(
      success: (teachers) => emit(state.copyWith(
        status: StudentCoursesStatus.loaded,
        subscribedTeachers: teachers,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadTeacherCourses(String teacherId) async {
    emit(state.copyWith(coursesStatus: StudentCoursesStatus.loading));
    final result = await _repo.getTeacherCourses(teacherId);
    result.when(
      success: (courses) => emit(state.copyWith(
        coursesStatus: StudentCoursesStatus.loaded,
        courses: courses,
      )),
      failure: (message, _) => emit(state.copyWith(
        coursesStatus: StudentCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadCourseLessons(String courseId) async {
    emit(state.copyWith(lessonsStatus: StudentCoursesStatus.loading));
    final result = await _repo.getCourseLessons(courseId);
    result.when(
      success: (lessons) => emit(state.copyWith(
        lessonsStatus: StudentCoursesStatus.loaded,
        lessons: lessons,
      )),
      failure: (message, _) => emit(state.copyWith(
        lessonsStatus: StudentCoursesStatus.error,
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
    final result = await _repo.updateLessonProgress(
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
    final result = await _repo.getStudentProgress(studentId);
    result.when(
      success: (progress) => emit(state.copyWith(progress: progress)),
      failure: (_, __) {},
    );
  }
}

enum StudentCoursesStatus { initial, loading, loaded, error }

class StudentCoursesState {
  final StudentCoursesStatus status;
  final List<Map<String, dynamic>> subscribedTeachers;
  final StudentCoursesStatus coursesStatus;
  final List<CourseModel> courses;
  final StudentCoursesStatus lessonsStatus;
  final List<LessonModel> lessons;
  final List<LessonProgressModel> progress;
  final String? errorMessage;

  const StudentCoursesState({
    this.status = StudentCoursesStatus.initial,
    this.subscribedTeachers = const [],
    this.coursesStatus = StudentCoursesStatus.initial,
    this.courses = const [],
    this.lessonsStatus = StudentCoursesStatus.initial,
    this.lessons = const [],
    this.progress = const [],
    this.errorMessage,
  });

  StudentCoursesState copyWith({
    StudentCoursesStatus? status,
    List<Map<String, dynamic>>? subscribedTeachers,
    StudentCoursesStatus? coursesStatus,
    List<CourseModel>? courses,
    StudentCoursesStatus? lessonsStatus,
    List<LessonModel>? lessons,
    List<LessonProgressModel>? progress,
    String? errorMessage,
  }) {
    return StudentCoursesState(
      status: status ?? this.status,
      subscribedTeachers: subscribedTeachers ?? this.subscribedTeachers,
      coursesStatus: coursesStatus ?? this.coursesStatus,
      courses: courses ?? this.courses,
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lessons: lessons ?? this.lessons,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}
