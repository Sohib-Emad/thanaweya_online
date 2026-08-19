import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
export 'package:thanaweya_online/features/student/logic/student_courses_state.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_state.dart';

/// Handles course listing, browsing, and teacher discovery.
class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  final StudentCoursesRepo _repo;

  StudentCoursesCubit({required StudentCoursesRepo repo})
      : _repo = repo,
        super(const StudentCoursesState());

  @override
  void emit(StudentCoursesState state) {
    if (!isClosed) super.emit(state);
  }

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

  Future<void> loadMyCourses(String studentId) async {
    emit(state.copyWith(myCoursesStatus: StudentCoursesStatus.loading));
    final result = await _repo.getMyCourses(studentId);
    result.when(
      success: (courses) => emit(state.copyWith(
        myCoursesStatus: StudentCoursesStatus.loaded,
        myCourses: courses,
      )),
      failure: (message, _) => emit(state.copyWith(
        myCoursesStatus: StudentCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadPopularCourses() async {
    emit(state.copyWith(popularCoursesStatus: StudentCoursesStatus.loading));
    final result = await _repo.getPopularCourses();
    result.when(
      success: (courses) => emit(state.copyWith(
        popularCoursesStatus: StudentCoursesStatus.loaded,
        popularCourses: courses,
      )),
      failure: (message, _) => emit(state.copyWith(
        popularCoursesStatus: StudentCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadCourse(String courseId) async {
    emit(state.copyWith(courseStatus: StudentCoursesStatus.loading, course: null));
    for (int attempt = 0; attempt < 4; attempt++) {
      final result = await _repo.getCourse(courseId);
      final data = result.when(success: (c) => c, failure: (_, __) => null);
      if (data != null && data.isNotEmpty) {
        emit(state.copyWith(
          courseStatus: StudentCoursesStatus.loaded, course: data,
        ));
        return;
      }
      if (attempt < 3) {
        await Future.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      }
    }
    emit(state.copyWith(courseStatus: StudentCoursesStatus.error, course: null));
  }

  Future<void> loadSubjects() async {
    final result = await _repo.getSubjects();
    result.when(
      success: (subjects) => emit(state.copyWith(subjects: subjects)),
      failure: (_, __) {},
    );
  }

  Future<void> loadApprovedTeachers() async {
    emit(state.copyWith(teachersStatus: StudentCoursesStatus.loading));
    final result = await _repo.getApprovedTeachers();
    result.when(
      success: (teachers) => emit(state.copyWith(
        teachersStatus: StudentCoursesStatus.loaded,
        approvedTeachers: teachers,
      )),
      failure: (message, _) => emit(state.copyWith(
        teachersStatus: StudentCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<void> loadTeacherCourses(String teacherId) async {
    emit(state.copyWith(coursesStatus: StudentCoursesStatus.loading));
    final result = await _repo.getTeacherCourses(teacherId);
    result.when(
      success: (courses) => emit(state.copyWith(
        coursesStatus: StudentCoursesStatus.loaded, courses: courses,
      )),
      failure: (message, _) => emit(state.copyWith(
        coursesStatus: StudentCoursesStatus.error, errorMessage: message,
      )),
    );
  }

  Future<void> loadCourseLessons(String courseId) async {
    emit(state.copyWith(lessonsStatus: StudentCoursesStatus.loading));
    final result = await _repo.lessons.getCourseLessons(courseId);
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

  Future<void> loadProgress(String studentId) async {
    final result = await _repo.lessons.getStudentProgress(studentId);
    result.when(
      success: (progress) => emit(state.copyWith(progress: progress)),
      failure: (_, __) {},
    );
  }

  Future<void> loadTeacherProfile(String teacherId) async {
    emit(state.copyWith(teacherProfileStatus: StudentCoursesStatus.loading));
    final result = await _repo.teacherProfile.getTeacherProfile(teacherId);
    result.when(
      success: (profile) => emit(state.copyWith(
        teacherProfileStatus: StudentCoursesStatus.loaded,
        teacherProfile: profile,
      )),
      failure: (message, _) => emit(state.copyWith(
        teacherProfileStatus: StudentCoursesStatus.error,
        errorMessage: message,
      )),
    );
  }
}
