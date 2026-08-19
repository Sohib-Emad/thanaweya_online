import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Document CRUD operations for teacher lessons.
class TeacherCoursesLessonsDocumentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Adds a document to a lesson.
  Future<ApiResult<void>> addLessonDocument({
    required String lessonId,
    required String title,
    required String fileUrl,
    String? fileType,
  }) async {
    try {
      await _client.from('lesson_documents').insert({
        'lesson_id': lessonId,
        'title': title,
        'file_url': fileUrl,
        'file_type': fileType,
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Documents published for a lesson.
  Future<ApiResult<List<Map<String, dynamic>>>> getLessonDocuments(
    String lessonId,
  ) async {
    try {
      final data = await _client
          .from('lesson_documents')
          .select('id, lesson_id, title, file_url, file_type, created_at')
          .eq('lesson_id', lessonId)
          .order('created_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes a lesson document by id.
  Future<ApiResult<void>> deleteLessonDocument(String documentId) async {
    try {
      await _client.from('lesson_documents').delete().eq('id', documentId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
