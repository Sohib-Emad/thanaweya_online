import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class StudentReviewsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getReviews(
      String courseId) async {
    try {
      final data = await _client
          .from('course_reviews')
          .select('id, rating, text, created_at, student_id')
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      final authorIds = data
          .map((e) => e['student_id'] as String)
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
      for (final review in data) {
        result.add({
          ...review,
          'users': profilesMap[review['student_id']] ?? {},
        });
      }
      return ApiResult.success(result);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<Map<String, dynamic>?>> getMyReview(
      String studentId, String courseId) async {
    try {
      final data = await _client
          .from('course_reviews')
          .select('id, rating, text, created_at')
          .eq('student_id', studentId)
          .eq('course_id', courseId)
          .maybeSingle();
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> saveReview({
    required String studentId,
    required String courseId,
    required int rating,
    String? text,
  }) async {
    try {
      await _client.from('course_reviews').upsert({
        'student_id': studentId,
        'course_id': courseId,
        'rating': rating,
        'text': text ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'course_id,student_id');
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteReview(
      String studentId, String courseId) async {
    try {
      await _client
          .from('course_reviews')
          .delete()
          .eq('student_id', studentId)
          .eq('course_id', courseId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
