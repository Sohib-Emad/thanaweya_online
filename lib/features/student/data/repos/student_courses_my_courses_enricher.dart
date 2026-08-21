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
            .select()
            .inFilter('id', courseIdSet.toList());
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

    final allCourseIds = coursesData
        .map((c) => c['id'] as String?)
        .whereType<String>()
        .toList();

    List<dynamic> lessonRows = [];
    List<dynamic> progressRows = [];
    if (allCourseIds.isNotEmpty) {
      try {
        lessonRows = await _client
            .from('lessons')
            .select('id, course_id')
            .inFilter('course_id', allCourseIds);
      } catch (_) {}
      try {
        progressRows = await _client
            .from('lesson_progress')
            .select('lesson_id, is_completed, view_count, watched_seconds')
            .eq('student_id', uid);
      } catch (_) {}
    }

    final courseLessonsMap = <String, List<String>>{};
    for (final l in lessonRows) {
      final cid = l['course_id'] as String? ?? '';
      final lid = l['id'] as String? ?? '';
      if (cid.isNotEmpty && lid.isNotEmpty) {
        courseLessonsMap.putIfAbsent(cid, () => []).add(lid);
      }
    }

    final completedLessonIds = <String>{};
    for (final p in progressRows) {
      final lid = p['lesson_id'] as String? ?? '';
      final isDone = (p['is_completed'] as bool?) ?? false;
      final viewCount = (p['view_count'] as num?)?.toInt() ?? 0;
      if (lid.isNotEmpty && (isDone || viewCount >= 3)) {
        completedLessonIds.add(lid);
      }
    }

    final result = <Map<String, dynamic>>[];
    for (final course in coursesData) {
      final cid = course['id'] as String? ?? '';
      final tid = course['teacher_id'] as String? ?? '';
      final teacher = teachersMap[tid] ?? {};
      final subjectId = teacher['subject_id'];
      final lessons = courseLessonsMap[cid] ?? [];
      final totalCount = lessons.length;
      final completedCount = lessons.where(completedLessonIds.contains).length;
      final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

      result.add({
        ...course,
        'teacher_name': (usersMap[tid]?['full_name'] as String?) ?? 'مدرس',
        'subject_name': subjectId != null
            ? (subjectsMap[subjectId]?['name_ar'] as String?) ?? ''
            : '',
        'subject_id': subjectId,
        'stage': teacher['stage'],
        'totalCount': totalCount,
        'completedCount': completedCount,
        'progress': progress,
        'isCompleted': progress >= 1.0 && totalCount > 0,
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
