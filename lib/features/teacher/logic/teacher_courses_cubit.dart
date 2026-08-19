import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
export 'package:thanaweya_online/features/teacher/logic/teacher_courses_state.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_state.dart';

/// Handles course listing, creation, and updates for teachers.
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
        status: TeacherCoursesStatus.loaded, courses: courses,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCoursesStatus.error, errorMessage: message,
      )),
    );
  }

  Future<void> createCourse({
    required String teacherId,
    required String title,
    String? description,
    String? coverImageUrl,
    double? price,
    String? introVideoUrl,
    String? introVideoSourceType,
    bool isPublished = false,
  }) async {
    emit(state.copyWith(status: TeacherCoursesStatus.loading));
    final result = await _repo.createCourse(
      teacherId: teacherId, title: title, description: description,
      coverImageUrl: coverImageUrl, price: price,
      introVideoUrl: introVideoUrl, introVideoSourceType: introVideoSourceType,
      isPublished: isPublished,
    );
    result.when(
      success: (course) => emit(state.copyWith(
        status: TeacherCoursesStatus.loaded,
        courses: [...state.courses, course],
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCoursesStatus.error, errorMessage: message,
      )),
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final result = await _repo.deleteCourse(courseId);
    result.when(
      success: (_) => emit(state.copyWith(
        courses: state.courses.where((c) => c.id != courseId).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> updateCourse({
    required String courseId,
    required String title,
    String? description,
    String? coverImageUrl,
    double? price,
    String? introVideoUrl,
    String? introVideoSourceType,
    bool? clearPrice,
    bool? clearIntroVideo,
    bool? isPublished,
  }) async {
    final result = await _repo.updateCourse(
      courseId: courseId, title: title, description: description,
      coverImageUrl: coverImageUrl, price: price,
      introVideoUrl: introVideoUrl, introVideoSourceType: introVideoSourceType,
      clearPrice: clearPrice, clearIntroVideo: clearIntroVideo,
      isPublished: isPublished,
    );
    result.when(
      success: (_) => emit(state.copyWith(
        courses: state.courses.map((c) {
          if (c.id != courseId) return c;
          return c.copyWith(
            title: title, description: description,
            coverImageUrl: coverImageUrl ?? c.coverImageUrl,
            price: clearPrice == true ? null : (price ?? c.price),
            introVideoUrl: clearIntroVideo == true
                ? null : (introVideoUrl ?? c.introVideoUrl),
            introVideoSourceType: clearIntroVideo == true
                ? null : (introVideoSourceType ?? c.introVideoSourceType),
            isPublished: isPublished ?? c.isPublished,
          );
        }).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
    );
  }

  Future<void> loadLessons(String courseId) async {
    emit(state.copyWith(status: TeacherCoursesStatus.loading));
    final result = await _repo.lessonsRepo.getLessons(courseId);
    result.when(
      success: (lessons) => emit(state.copyWith(
        status: TeacherCoursesStatus.loaded, lessons: lessons,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCoursesStatus.error, errorMessage: message,
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
    emit(state.copyWith(status: TeacherCoursesStatus.loading));
    final result = await _repo.lessonsRepo.addLesson(
      courseId: courseId, title: title, description: description,
      videoSourceType: videoSourceType, videoUrlOrId: videoUrlOrId,
      isFreePreview: isFreePreview,
    );
    result.when(
      success: (lesson) => emit(state.copyWith(
        status: TeacherCoursesStatus.loaded,
        lessons: [...state.lessons, lesson],
      )),
      failure: (message, _) => emit(state.copyWith(
        status: TeacherCoursesStatus.error, errorMessage: message,
      )),
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
      lessonId: lessonId, title: title, description: description,
      videoUrlOrId: videoUrlOrId, isFreePreview: isFreePreview,
    );
    result.when(
      success: (_) => emit(state.copyWith(
        lessons: state.lessons.map((l) {
          if (l.id != lessonId) return l;
          return l.copyWith(
            title: title, description: description,
            videoUrlOrId: videoUrlOrId ?? l.videoUrlOrId,
            isFreePreview: isFreePreview ?? l.isFreePreview,
          );
        }).toList(),
      )),
      failure: (message, _) => emit(state.copyWith(errorMessage: message)),
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
}
