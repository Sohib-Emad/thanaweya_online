import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';

enum StudentCoursesStatus { initial, loading, loaded, error }

class StudentCoursesState {
  final StudentCoursesStatus status;
  final List<Map<String, dynamic>> subscribedTeachers;
  final StudentCoursesStatus myCoursesStatus;
  final List<Map<String, dynamic>> myCourses;
  final StudentCoursesStatus popularCoursesStatus;
  final List<Map<String, dynamic>> popularCourses;
  final StudentCoursesStatus courseStatus;
  final Map<String, dynamic>? course;
  final StudentCoursesStatus coursesStatus;
  final List<CourseModel> courses;
  final StudentCoursesStatus teachersStatus;
  final List<Map<String, dynamic>> approvedTeachers;
  final List<Map<String, dynamic>> subjects;
  final String? errorMessage;
  final Map<String, dynamic>? teacherProfile;
  final StudentCoursesStatus teacherProfileStatus;
  final StudentCoursesStatus lessonsStatus;
  final List<LessonModel> lessons;
  final List<LessonProgressModel> progress;
  final List<Map<String, dynamic>> courseExams;
  final List<Map<String, dynamic>> examSubmissions;

  const StudentCoursesState({
    this.status = StudentCoursesStatus.initial,
    this.subscribedTeachers = const [],
    this.myCoursesStatus = StudentCoursesStatus.initial,
    this.myCourses = const [],
    this.popularCoursesStatus = StudentCoursesStatus.initial,
    this.popularCourses = const [],
    this.courseStatus = StudentCoursesStatus.initial,
    this.course,
    this.coursesStatus = StudentCoursesStatus.initial,
    this.courses = const [],
    this.teachersStatus = StudentCoursesStatus.initial,
    this.approvedTeachers = const [],
    this.subjects = const [],
    this.errorMessage,
    this.teacherProfile,
    this.teacherProfileStatus = StudentCoursesStatus.initial,
    this.lessonsStatus = StudentCoursesStatus.initial,
    this.lessons = const [],
    this.progress = const [],
    this.courseExams = const [],
    this.examSubmissions = const [],
  });

  StudentCoursesState copyWith({
    StudentCoursesStatus? status,
    List<Map<String, dynamic>>? subscribedTeachers,
    StudentCoursesStatus? myCoursesStatus,
    List<Map<String, dynamic>>? myCourses,
    StudentCoursesStatus? popularCoursesStatus,
    List<Map<String, dynamic>>? popularCourses,
    StudentCoursesStatus? courseStatus,
    Map<String, dynamic>? course,
    StudentCoursesStatus? coursesStatus,
    List<CourseModel>? courses,
    StudentCoursesStatus? teachersStatus,
    List<Map<String, dynamic>>? approvedTeachers,
    List<Map<String, dynamic>>? subjects,
    String? errorMessage,
    Map<String, dynamic>? teacherProfile,
    StudentCoursesStatus? teacherProfileStatus,
    StudentCoursesStatus? lessonsStatus,
    List<LessonModel>? lessons,
    List<LessonProgressModel>? progress,
    List<Map<String, dynamic>>? courseExams,
    List<Map<String, dynamic>>? examSubmissions,
  }) {
    return StudentCoursesState(
      status: status ?? this.status,
      subscribedTeachers: subscribedTeachers ?? this.subscribedTeachers,
      myCoursesStatus: myCoursesStatus ?? this.myCoursesStatus,
      myCourses: myCourses ?? this.myCourses,
      popularCoursesStatus: popularCoursesStatus ?? this.popularCoursesStatus,
      popularCourses: popularCourses ?? this.popularCourses,
      courseStatus: courseStatus ?? this.courseStatus,
      course: course ?? this.course,
      coursesStatus: coursesStatus ?? this.coursesStatus,
      courses: courses ?? this.courses,
      teachersStatus: teachersStatus ?? this.teachersStatus,
      approvedTeachers: approvedTeachers ?? this.approvedTeachers,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage,
      teacherProfile: teacherProfile ?? this.teacherProfile,
      teacherProfileStatus: teacherProfileStatus ?? this.teacherProfileStatus,
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lessons: lessons ?? this.lessons,
      progress: progress ?? this.progress,
      courseExams: courseExams ?? this.courseExams,
      examSubmissions: examSubmissions ?? this.examSubmissions,
    );
  }
}
