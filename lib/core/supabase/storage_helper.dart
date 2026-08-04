import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageHelper {
  StorageHelper._();

  static final SupabaseClient _client = Supabase.instance.client;

  static const String _teacherBucket = 'teacher-documents';

  /// Uploads a teacher document (avatar, ID card, proof) to Supabase Storage.
  /// [folder] is the user ID, [subfolder] is like 'avatar', 'id_front', etc.
  /// Returns the public URL of the uploaded file, or null on failure.
  static Future<String?> uploadTeacherDocument({
    required String userId,
    required String subfolder,
    required XFile file,
  }) async {
    try {
      final ext = p.extension(file.path).replaceAll('.', '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$userId/$subfolder/$fileName';

      final fileBytes = await file.readAsBytes();

      await _client.storage.from(_teacherBucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _client.storage.from(_teacherBucket).getPublicUrl(path);
      debugPrint('[StorageHelper] uploaded: $path -> $url');
      return url;
    } catch (e) {
      debugPrint('[StorageHelper] upload failed for $subfolder: $e');
      return null;
    }
  }

  /// Uploads multiple teacher documents concurrently.
  /// Returns a map of subfolder -> public URL (only successful uploads).
  static Future<Map<String, String>> uploadTeacherDocuments({
    required String userId,
    required Map<String, XFile?> files,
  }) async {
    final results = <String, String>{};

    for (final entry in files.entries) {
      if (entry.value == null) continue;
      final url = await uploadTeacherDocument(
        userId: userId,
        subfolder: entry.key,
        file: entry.value!,
      );
      if (url != null) {
        results[entry.key] = url;
      }
    }

    return results;
  }
}
