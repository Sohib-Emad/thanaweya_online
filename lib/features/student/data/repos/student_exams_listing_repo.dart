import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_enrichment_repo.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_fetcher_repo.dart';

/// Exam listing and attempt-counting logic extracted from [StudentExamsRepo].
class StudentExamsListingRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final StudentExamsEnrichmentRepo _enrichment = StudentExamsEnrichmentRepo();
  final StudentExamsFetcherRepo _fetcher = StudentExamsFetcherRepo();

  /// Fetches published exams available to a student, enriched with metadata.
  Future<ApiResult<List<Map<String, dynamic>>>> getAvailableExams(
    String studentId,
  ) async {
    try {
      final uid = _client.auth.currentUser?.id ??
          _client.auth.currentSession?.user.id ??
          studentId;
      if (uid.isEmpty) return const ApiResult.success([]);

      final teacherIdSet = <String>{};
      final courseIdSet = <String>{};
      await _collectSubscriptionIds(uid, teacherIdSet, courseIdSet);
      await _resolveCourseTeachers(courseIdSet, teacherIdSet);
      if (teacherIdSet.isEmpty && courseIdSet.isEmpty) {
        return const ApiResult.success([]);
      }

      final examsData = await _fetcher.fetchExams(teacherIdSet, courseIdSet);
      if (examsData.isEmpty) return const ApiResult.success([]);

      final questionCountMap = await _enrichment.countQuestions(examsData);
      final teacherNames = await _enrichment.resolveTeacherNames(examsData);
      final courseTitles = await _enrichment.resolveCourseTitles(examsData);
      final attemptsMap = await _enrichment.getAttemptsCounts(uid, examsData);

      final result = examsData.map((exam) {
        final examId = exam['id'] as String? ?? '';
        final tId = exam['teacher_id'] as String? ?? '';
        final cId = exam['course_id'] as String? ?? '';
        final maxAttempts = (exam['max_attempts'] as num?)?.toInt() ?? 3;
        return {
          ...exam,
          'teacher_name': teacherNames[tId] ?? 'المعلم',
          'course_title': courseTitles[cId] ?? '',
          'subject_name': courseTitles[cId]?.isNotEmpty == true
              ? courseTitles[cId]!
              : (teacherNames[tId] ?? ''),
          'max_attempts': maxAttempts,
          'attempts_used': attemptsMap[examId] ?? 0,
          'questions_count': questionCountMap[examId] ?? 0,
          'is_subscribed': teacherIdSet.contains(tId),
        };
      }).toList()
        ..sort((a, b) =>
            (b['created_at'] as String? ?? '').compareTo(a['created_at'] as String? ?? ''));

      return ApiResult.success(result);
    } catch (_) {
      return const ApiResult.success([]);
    }
  }

  Future<void> _collectSubscriptionIds(
    String uid,
    Set<String> teacherIds,
    Set<String> courseIds,
  ) async {
    try {
      final subRes = await _client
          .from('subscriptions')
          .select('teacher_id, course_id')
          .eq('student_id', uid);
      for (final s in subRes) {
        final tId = s['teacher_id'] as String?;
        final cId = s['course_id'] as String?;
        if (tId != null && tId.isNotEmpty) teacherIds.add(tId);
        if (cId != null && cId.isNotEmpty) courseIds.add(cId);
      }
    } catch (_) {}
    try {
      final payRes = await _client
          .from('payments')
          .select('course_id')
          .eq('payer_id', uid)
          .inFilter('status', ['success', 'completed']);
      for (final p in payRes) {
        final cId = p['course_id'] as String?;
        if (cId != null && cId.isNotEmpty) courseIds.add(cId);
      }
    } catch (_) {}
    for (final field in ['used_by_student_id', 'used_by']) {
      try {
        final codeRes = await _client
            .from('activation_codes')
            .select('teacher_id, course_id')
            .eq(field, uid);
        for (final c in codeRes) {
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

  Future<void> _resolveCourseTeachers(
    Set<String> courseIds,
    Set<String> teacherIds,
  ) async {
    if (courseIds.isEmpty) return;
    try {
      final cRows = await _client
          .from('courses')
          .select('teacher_id')
          .inFilter('id', courseIds.toList());
      for (final r in cRows) {
        final tId = r['teacher_id'] as String?;
        if (tId != null && tId.isNotEmpty) teacherIds.add(tId);
      }
    } catch (_) {}
  }
}
