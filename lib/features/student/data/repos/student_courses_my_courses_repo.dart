import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_my_courses_enricher.dart';

/// Fetching "my courses" and subscribed teachers for the student.
class StudentCoursesMyCoursesRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final StudentCoursesMyCoursesEnricher _enricher =
      StudentCoursesMyCoursesEnricher();

  /// Enriched "my courses" with teacher/subject info and lesson progress.
  Future<ApiResult<List<Map<String, dynamic>>>> getMyCourses(
    String studentId,
  ) async {
    try {
      final uid = _client.auth.currentUser?.id ??
          _client.auth.currentSession?.user.id ??
          studentId;
      if (uid.isEmpty) return const ApiResult.success([]);
      final teacherIdSet = <String>{};
      final courseIdSet = <String>{};
      await _collectMyCourseIds(uid, teacherIdSet, courseIdSet);
      if (teacherIdSet.isEmpty && courseIdSet.isEmpty) {
        return const ApiResult.success([]);
      }
      return await _enricher.buildMyCoursesResult(uid, teacherIdSet, courseIdSet);
    } catch (_) {
      return const ApiResult.success([]);
    }
  }

  Future<void> _collectMyCourseIds(
    String uid,
    Set<String> teacherIds,
    Set<String> courseIds,
  ) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('teacher_id, course_id')
          .eq('student_id', uid);
      for (final s in subData) {
        final tId = s['teacher_id'] as String?;
        final cId = s['course_id'] as String?;
        if (tId != null && tId.isNotEmpty) teacherIds.add(tId);
        if (cId != null && cId.isNotEmpty) courseIds.add(cId);
      }
    } catch (_) {}
    try {
      final payData = await _client
          .from('payments')
          .select('course_id')
          .eq('payer_id', uid)
          .inFilter('status', ['success', 'completed']);
      for (final p in payData) {
        final cId = p['course_id'] as String?;
        if (cId != null && cId.isNotEmpty) courseIds.add(cId);
      }
    } catch (_) {}
    for (final field in ['used_by_student_id', 'used_by']) {
      try {
        final codeData = await _client
            .from('activation_codes')
            .select('teacher_id, course_id')
            .eq(field, uid);
        for (final c in codeData) {
          final tId = c['teacher_id'] as String?;
          final cId = c['course_id'] as String?;
          if (tId != null && tId.isNotEmpty) teacherIds.add(tId);
          if (cId != null && cId.isNotEmpty) courseIds.add(cId);
        }
      } catch (_) {}
    }
    try {
      final progData = await _client
          .from('lesson_progress')
          .select('lesson_id')
          .eq('student_id', uid);
      final lIds = progData
          .map((e) => e['lesson_id'] as String?)
          .whereType<String>()
          .toList();
      if (lIds.isNotEmpty) {
        final rows = await _client
            .from('lessons')
            .select('course_id')
            .inFilter('id', lIds);
        for (final l in rows) {
          final cId = l['course_id'] as String?;
          if (cId != null && cId.isNotEmpty) courseIds.add(cId);
        }
      }
    } catch (_) {}
  }
}
