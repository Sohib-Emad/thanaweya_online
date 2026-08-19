import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Teacher-profile fetching logic extracted from [StudentCoursesRepo].
class StudentCoursesTeacherProfileRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches complete teacher profile for teacher details page.
  Future<ApiResult<Map<String, dynamic>>> getTeacherProfile(
    String teacherId,
  ) async {
    try {
      Map<String, dynamic> data;
      try {
        data = await _client
            .from('teachers')
            .select('''
              id, stage, bio, approval_status, created_at,
              teaching_system, governorate, teaching_mode, stages,
              baccalaureate_tracks,
              users!inner(id, full_name, avatar_url, phone),
              subjects(id, name_ar)
            ''')
            .eq('id', teacherId)
            .single();
      } catch (_) {
        data = await _fetchProfileFallback(teacherId);
      }
      return ApiResult.success(Map<String, dynamic>.from(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> _fetchProfileFallback(String teacherId) async {
    final teacher = await _client
        .from('teachers')
        .select(
          'id, stage, bio, approval_status, created_at, teaching_system, '
          'governorate, teaching_mode, stages, baccalaureate_tracks, subject_id',
        )
        .eq('id', teacherId)
        .single();

    Map<String, dynamic>? user;
    try {
      user = await _client
          .from('users')
          .select('id, full_name, avatar_url, phone')
          .eq('id', teacherId)
          .maybeSingle();
    } catch (_) {}

    Map<String, dynamic>? subject;
    final sId = teacher['subject_id'] as String?;
    if (sId != null && sId.isNotEmpty) {
      try {
        subject = await _client
            .from('subjects')
            .select('id, name_ar')
            .eq('id', sId)
            .maybeSingle();
      } catch (_) {}
    }

    return {...teacher, 'users': user ?? {}, 'subjects': subject};
  }
}
