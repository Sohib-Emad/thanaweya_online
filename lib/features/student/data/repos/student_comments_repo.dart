import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/comment_model.dart';

class StudentCommentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getComments(
      String lessonId) async {
    try {
      final data = await _client
          .from('comments')
          .select('id, lesson_id, author_id, text, created_at')
          .eq('lesson_id', lessonId)
          .order('created_at', ascending: true);

      final authorIds = data
          .map((e) => e['author_id'] as String)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      var profiles = <Map<String, dynamic>>[];
      if (authorIds.isNotEmpty) {
        profiles = await _client
            .from('user_profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', authorIds);
      }

      final profilesMap = {
        for (final p in profiles) p['id'] as String: p,
      };

      final result = <Map<String, dynamic>>[];
      for (final comment in data) {
        result.add({
          ...comment,
          'users': profilesMap[comment['author_id']] ?? {},
        });
      }
      return ApiResult.success(result);
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
