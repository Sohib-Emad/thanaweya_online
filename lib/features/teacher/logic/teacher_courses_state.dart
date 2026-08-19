import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

enum TeacherCoursesStatus { initial, loading, loaded, error }

class TeacherCoursesState {
  final TeacherCoursesStatus status;
  final List<CourseModel> courses;
  final List<LessonModel> lessons;
  final TeacherCoursesStatus lessonsStatus;
  final String? errorMessage;

  const TeacherCoursesState({
    this.status = TeacherCoursesStatus.initial,
    this.courses = const [],
    this.lessons = const [],
    this.lessonsStatus = TeacherCoursesStatus.initial,
    this.errorMessage,
  });

  TeacherCoursesState copyWith({
    TeacherCoursesStatus? status,
    List<CourseModel>? courses,
    List<LessonModel>? lessons,
    TeacherCoursesStatus? lessonsStatus,
    String? errorMessage,
  }) {
    return TeacherCoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      lessons: lessons ?? this.lessons,
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      errorMessage: errorMessage,
    );
  }
}
