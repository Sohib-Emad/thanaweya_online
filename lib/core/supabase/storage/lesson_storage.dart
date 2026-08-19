import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'storage_utils.dart';

/// Uploads lesson-specific files (videos, documents) to Supabase Storage.
class LessonStorage {
  LessonStorage._();

  static final SupabaseClient _client = Supabase.instance.client;
  static const String _videoBucket = 'lesson-videos';
  static const String _documentBucket = 'lesson-documents';

  /// Uploads a lesson video to the `lesson-videos` bucket.
  ///
  /// Returns the public URL on success, or `null` on failure.
  static Future<String?> uploadVideo({
    required String teacherId,
    required String courseId,
    required XFile file,
  }) async {
    try {
      final ext = p.extension(file.path).replaceAll('.', '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$teacherId/$courseId/$fileName';
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
      debugPrint('[StorageHelper] lesson video uploaded: $path -> $url');
      return url;
    } catch (e) {
      debugPrint('[StorageHelper] lesson video upload failed: $e');
      return null;
    }
  }

  /// Uploads a lesson document (PDF/image) to the `lesson-documents` bucket.
  ///
  /// Returns the public URL on success, or `null` on failure.
  static Future<String?> uploadDocument({
    required String teacherId,
    required String lessonId,
    required XFile file,
  }) async {
    try {
      final ext = p.extension(file.path).replaceAll('.', '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$teacherId/$lessonId/$fileName';
      final fileBytes = await file.readAsBytes();

      await _client.storage.from(_documentBucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: StorageUtils.resolveMimeType(ext),
            ),
          );

      final url = _client.storage.from(_documentBucket).getPublicUrl(path);
      debugPrint('[StorageHelper] lesson doc uploaded: $path -> $url');
      return url;
    } catch (e) {
      debugPrint('[StorageHelper] lesson document upload failed: $e');
      return null;
    }
  }
}
