import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_popular_repo.dart';

/// Course discovery and teacher browsing logic.
class StudentCoursesDiscoveryRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final StudentCoursesPopularRepo popular = StudentCoursesPopularRepo();

  /// Fetches active subjects.
  Future<ApiResult<List<Map<String, dynamic>>>> getSubjects() async {
    try {
      final data = await _client
          .from('subjects')
          .select('id, name_ar, name_en, icon_name')
          .eq('is_active', true)
          .order('display_order');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches all approved teachers for discovery.
  Future<ApiResult<List<Map<String, dynamic>>>> getApprovedTeachers() async {
    try {
      List<dynamic> data;
      try {
        data = await _client
            .from('teachers')
            .select(
              'id, stage, bio, approval_status, created_at, '
              'users!inner(id, full_name, avatar_url), subjects(id, name_ar)',
            )
            .eq('approval_status', 'approved')
            .order('created_at');
      } catch (_) {
        data = await _fetchApprovedTeachersFallback();
      }
      return ApiResult.success(data.cast<Map<String, dynamic>>());
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<List<dynamic>> _fetchApprovedTeachersFallback() async {
    final teachers = await _client
        .from('teachers')
        .select('id, stage, bio, approval_status, subject_id, created_at')
        .eq('approval_status', 'approved')
        .order('created_at');
    final tIds = teachers.map((t) => t['id'] as String).toList();
    final users = tIds.isNotEmpty
        ? await _client
              .from('users')
              .select('id, full_name, avatar_url')
              .inFilter('id', tIds)
        : [];
    final usersMap = {for (final u in users) u['id'] as String: u};
    final sIds = teachers
        .map((t) => t['subject_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final subjects = sIds.isNotEmpty
        ? await _client
              .from('subjects')
              .select('id, name_ar')
              .inFilter('id', sIds)
        : [];
    final subjectsMap = {for (final s in subjects) s['id'] as String: s};
    return teachers.map((t) {
      final tId = t['id'] as String;
      final sId = t['subject_id'] as String?;
      return {
        ...t,
        'users': usersMap[tId] ?? {},
        'subjects': sId != null ? subjectsMap[sId] : null,
      };
    }).toList();
  }
}
