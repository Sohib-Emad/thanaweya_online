import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/comment_model.dart';

class StudentCommentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getComments(
      String lessonId) async {
    try {
      final data = await _client.from('comments').select('''
            id, lesson_id, author_id, text, created_at,
            users!inner(id, full_name, avatar_url, role)
          ''').eq('lesson_id', lessonId).order('created_at', ascending: true);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<CommentModel>> addComment({
    required String lessonId,
    required String authorId,
    required String text,
  }) async {
    try {
      final data = await _client
          .from('comments')
          .insert({
            'lesson_id': lessonId,
            'author_id': authorId,
            'text': text,
          })
          .select()
          .single();
      return ApiResult.success(CommentModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteComment(String commentId) async {
    try {
      await _client.from('comments').delete().eq('id', commentId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
