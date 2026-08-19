import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'storage_utils.dart';

/// Uploads teacher identity documents (avatar, ID card, proof of employment)
/// to the `teacher-documents` Supabase Storage bucket.
class TeacherDocumentStorage {
  TeacherDocumentStorage._();

  static final SupabaseClient _client = Supabase.instance.client;
  static const String _bucket = 'teacher-documents';

  /// Uploads a single teacher document.
  ///
  /// [subfolder] is the document category (e.g. 'avatar', 'id_front').
  /// Returns the public URL on success, or `null` on failure.
  static Future<String?> upload({
    required String userId,
    required String subfolder,
    required XFile file,
  }) async {
    try {
      final ext = p.extension(file.path).replaceAll('.', '');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$userId/$subfolder/$fileName';
      final fileBytes = await file.readAsBytes();

      await _client.storage.from(_bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: StorageUtils.resolveMimeType(ext),
            ),
          );

      final url = _client.storage.from(_bucket).getPublicUrl(path);
      debugPrint('[StorageHelper] uploaded: $path -> $url');
      return url;
    } catch (e) {
      debugPrint('[StorageHelper] upload failed for $subfolder: $e');
      return null;
    }
  }

  /// Uploads multiple teacher documents concurrently.
  ///
  /// Returns a map of `subfolder -> public URL` for successful uploads only.
  static Future<Map<String, String>> uploadMultiple({
    required String userId,
    required Map<String, XFile?> files,
  }) async {
    final results = <String, String>{};

    for (final entry in files.entries) {
      if (entry.value == null) continue;
      final url = await upload(
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
