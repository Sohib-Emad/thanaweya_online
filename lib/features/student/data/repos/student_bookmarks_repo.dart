import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class StudentBookmarksRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getBookmarks(
      String studentId) async {
    try {
      final data = await _client
          .from('bookmarks')
          .select('''
            id, created_at,
            courses(
              id, teacher_id, title, description, cover_image_url, is_published, "order", created_at, updated_at,
              teachers(id, subject_id, users(id, full_name), subjects(id, name_ar))
            )
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<bool>> isBookmarked(
      String studentId, String courseId) async {
    try {
      final data = await _client
          .from('bookmarks')
          .select('id')
          .eq('student_id', studentId)
          .eq('course_id', courseId)
          .maybeSingle();
      return ApiResult.success(data != null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> addBookmark(
      String studentId, String courseId) async {
    try {
      await _client.from('bookmarks').insert({
        'student_id': studentId,
        'course_id': courseId,
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> removeBookmark(
      String studentId, String courseId) async {
    try {
      await _client
          .from('bookmarks')
          .delete()
          .eq('student_id', studentId)
          .eq('course_id', courseId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
