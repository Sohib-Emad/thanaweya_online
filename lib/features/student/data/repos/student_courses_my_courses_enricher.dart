import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';

/// Enrichment helpers for "my courses" with teacher/subject info.
class StudentCoursesMyCoursesEnricher {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> buildMyCoursesResult(
    String uid,
    Set<String> teacherIdSet,
    Set<String> courseIdSet,
  ) async {
    final coursesData = <Map<String, dynamic>>[];
    final seen = <String>{};
    if (courseIdSet.isNotEmpty) {
      try {
        final rows = await _client
            .from('courses')
            .select(
              'id, teacher_id, title, description, cover_image_url, price, '
              'intro_video_url, intro_video_source_type, is_published, '
              '"order", created_at, updated_at',
            )
            .inFilter('id', courseIdSet.toList())
            .order('order');
        for (final c in rows) {
          final id = c['id'] as String? ?? '';
          if (id.isNotEmpty && seen.add(id)) coursesData.add(c);
        }
      } catch (_) {}
    }
    if (teacherIdSet.isNotEmpty) {
      try {
        final rows = await _client
            .from('courses')
            .select(
              'id, teacher_id, title, description, cover_image_url, price, '
              'intro_video_url, intro_video_source_type, is_published, '
              '"order", created_at, updated_at',
            )
            .inFilter('teacher_id', teacherIdSet.toList())
            .order('order');
        for (final c in rows) {
          final id = c['id'] as String? ?? '';
          if (id.isNotEmpty && seen.add(id)) coursesData.add(c);
        }
      } catch (_) {}
    }
    if (coursesData.isEmpty) return const ApiResult.success([]);
    return await _enrichCourses(uid, coursesData);
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _enrichCourses(
    String uid,
    List<Map<String, dynamic>> coursesData,
  ) async {
    final allTeacherIds = coursesData
        .map((c) => c['teacher_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final teacherRows = await _fetchRows(
      'teachers', 'id, subject_id, stage, bio', allTeacherIds,
    );
    final userRows = await _fetchRows(
      'users', 'id, full_name, avatar_url', allTeacherIds,
    );
    final subjectIds = teacherRows
        .map((t) => t['subject_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final subjectRows = await _fetchRows('subjects', 'id, name_ar', subjectIds);
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

  Future<List<dynamic>> _fetchRows(
    String table, String columns, List<String> ids,
  ) async {
    if (ids.isEmpty) return [];
    try {
      return await _client.from(table).select(columns).inFilter('id', ids);
    } catch (_) {}
    return [];
  }
}
