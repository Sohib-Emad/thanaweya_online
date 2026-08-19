import 'package:image_picker/image_picker.dart';

import 'storage/teacher_document_storage.dart';
import 'storage/course_storage.dart';
import 'storage/lesson_storage.dart';

/// Backward-compatible facade that delegates to domain-specific storage
/// helpers: [TeacherDocumentStorage], [CourseStorage], and [LessonStorage].
class StorageHelper {
  StorageHelper._();

  /// Uploads a teacher document (avatar, ID card, proof).
  static Future<String?> uploadTeacherDocument({
    required String userId,
    required String subfolder,
    required XFile file,
  }) =>
      TeacherDocumentStorage.upload(
        userId: userId,
        subfolder: subfolder,
        file: file,
      );

  /// Uploads multiple teacher documents concurrently.
  static Future<Map<String, String>> uploadTeacherDocuments({
    required String userId,
    required Map<String, XFile?> files,
  }) =>
      TeacherDocumentStorage.uploadMultiple(userId: userId, files: files);

  /// Uploads a course cover image.
  static Future<String?> uploadCourseCover({
    required String teacherId,
    required String courseId,
    required XFile file,
  }) =>
      CourseStorage.uploadCover(
        teacherId: teacherId,
        courseId: courseId,
        file: file,
      );

  /// Uploads a lesson video.
  static Future<String?> uploadLessonVideo({
    required String teacherId,
    required String courseId,
    required XFile file,
  }) =>
      LessonStorage.uploadVideo(
        teacherId: teacherId,
        courseId: courseId,
        file: file,
      );

  /// Uploads a course intro video.
  static Future<String?> uploadCourseIntroVideo({
    required String teacherId,
    required String courseId,
    required XFile file,
  }) =>
      CourseStorage.uploadIntroVideo(
        teacherId: teacherId,
        courseId: courseId,
        file: file,
      );

  /// Uploads a lesson document (PDF/image).
  static Future<String?> uploadLessonDocument({
    required String teacherId,
    required String lessonId,
    required XFile file,
  }) =>
      LessonStorage.uploadDocument(
        teacherId: teacherId,
        lessonId: lessonId,
        file: file,
      );
}
