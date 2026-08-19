import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Popular courses listing and enrichment for student discovery.
class StudentCoursesPopularRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// All published courses of approved teachers, enriched with teacher/subject info.
  Future<ApiResult<List<Map<String, dynamic>>>> getPopularCourses() async {
    try {
      List<dynamic> teacherRows = [];
      try {
        teacherRows = await _client
            .from('teachers')
            .select('id, subject_id, stage')
            .eq('approval_status', 'approved');
      } catch (_) {}
      final teacherIds = teacherRows.map((t) => t['id'] as String).toList();
      final coursesData = teacherIds.isNotEmpty
          ? await _fetchPublishedCoursesByTeachers(teacherIds)
          : await _fetchAllPublishedCourses();
      if (coursesData.isEmpty) return const ApiResult.success([]);
      return await _buildPopularCoursesResult(coursesData, teacherRows);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<List<dynamic>> _fetchPublishedCoursesByTeachers(
    List<String> ids,
  ) async {
    return _client
        .from('courses')
        .select(
          'id, teacher_id, title, description, cover_image_url, price, '
          'intro_video_url, intro_video_source_type, is_published, '
          '"order", created_at, updated_at, lessons(count)',
        )
        .inFilter('teacher_id', ids)
        .eq('is_published', true)
        .order('order');
  }

  Future<List<dynamic>> _fetchAllPublishedCourses() async {
    return _client
        .from('courses')
        .select(
          'id, teacher_id, title, description, cover_image_url, price, '
          'intro_video_url, intro_video_source_type, is_published, '
          '"order", created_at, updated_at, lessons(count)',
        )
        .eq('is_published', true)
        .order('order');
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _buildPopularCoursesResult(
    List<dynamic> coursesData,
    List<dynamic> teacherRows,
  ) async {
    final teacherIds = coursesData
        .map((c) => c['teacher_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    List<dynamic> userRows = [];
    if (teacherIds.isNotEmpty) {
      try {
        userRows = await _client
            .from('users')
            .select('id, full_name, avatar_url')
            .inFilter('id', teacherIds);
      } catch (_) {}
    }
    if (teacherRows.isEmpty && teacherIds.isNotEmpty) {
      try {
        teacherRows = await _client
            .from('teachers')
            .select('id, subject_id, stage')
            .inFilter('id', teacherIds);
      } catch (_) {}
    }
    final subjectIds = teacherRows
        .map((t) => t['subject_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    List<dynamic> subjectRows = [];
    if (subjectIds.isNotEmpty) {
      try {
        subjectRows = await _client
            .from('subjects')
            .select('id, name_ar')
            .inFilter('id', subjectIds);
      } catch (_) {}
    }
    final usersMap = {for (final u in userRows) (u['id'] ?? ''): u};
    final teachersMap = {for (final t in teacherRows) (t['id'] ?? ''): t};
    final subjectsMap = {for (final s in subjectRows) (s['id'] ?? ''): s};
    final result = <Map<String, dynamic>>[];
    for (final course in coursesData) {
      final tid = course['teacher_id'] as String? ?? '';
      final teacher = teachersMap[tid] ?? {};
      final subjectId = teacher['subject_id'];
      result.add({
        ...course,
        'teacher_name': (usersMap[tid]?['full_name'] as String?) ?? 'مدرس',
        'subject_name': subjectId != null
            ? (subjectsMap[subjectId]?['name_ar'] as String?) ?? ''
            : '',
        'subject_id': subjectId,
        'stage': teacher['stage'],
      });
    }
    return ApiResult.success(result);
  }
}
