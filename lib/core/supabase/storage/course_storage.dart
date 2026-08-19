import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'storage_utils.dart';

/// Uploads course-related media (cover images, intro videos) to Supabase
/// Storage.
class CourseStorage {
  CourseStorage._();

  static final SupabaseClient _client = Supabase.instance.client;
  static const String _teacherBucket = 'teacher-documents';
  static const String _videoBucket = 'lesson-videos';

  /// Uploads a course cover image to the `teacher-documents` bucket.
  ///
  /// Returns the public URL on success, or `null` on failure.
  static Future<String?> uploadCover({
    required String teacherId,
    required String courseId,
    required XFile file,
  }) async {
    try {
      final ext = p.extension(file.path).replaceAll('.', '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$teacherId/covers/$courseId/$fileName';
      final fileBytes = await file.readAsBytes();

      await _client.storage.from(_teacherBucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: StorageUtils.resolveMimeType(ext),
            ),
          );

      final url = _client.storage.from(_teacherBucket).getPublicUrl(path);
      debugPrint('[StorageHelper] course cover uploaded: $path -> $url');
      return url;
    } catch (e) {
      debugPrint('[StorageHelper] course cover upload failed: $e');
      return null;
    }
  }

  /// Uploads a course intro video to the `lesson-videos` bucket.
  ///
  /// Returns the public URL on success, or `null` on failure.
  static Future<String?> uploadIntroVideo({
    required String teacherId,
    required String courseId,
    required XFile file,
  }) async {
    try {
      final ext = p.extension(file.path).replaceAll('.', '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$teacherId/$courseId/intro_$fileName';
      final fileBytes = await file.readAsBytes();

      await _client.storage.from(_videoBucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: StorageUtils.resolveMimeType(ext),
            ),
          );

      final url = _client.storage.from(_videoBucket).getPublicUrl(path);
      debugPrint('[StorageHelper] intro video uploaded: $path -> $url');
      return url;
    } catch (e) {
      debugPrint('[StorageHelper] course intro video upload failed: $e');
      return null;
    }
  }
}
