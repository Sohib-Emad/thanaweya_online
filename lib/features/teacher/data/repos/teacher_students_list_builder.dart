import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';

/// Queries subscription, activation-code, and progress tables to discover
/// which students belong to a given teacher, then enriches them with
/// profile and progress data.
class TeacherStudentsListBuilder {
  final SupabaseClient _client = Supabase.instance.client;

  /// Discovers student IDs from subscriptions, codes, payments, and exams.
  Future<void> collectStudentIds(
    String teacherId,
    Set<String> ids,
    Map<String, String> statusMap,
    Map<String, String> dateMap,
  ) async {
    // 1. Direct subscriptions
    try {
      final subs = await _client
          .from('subscriptions')
          .select('student_id, status, created_at')
          .eq('teacher_id', teacherId);
      for (final s in subs) {
        final sId = s['student_id'] as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap[sId] = s['status'] as String? ?? 'active';
          dateMap[sId] = s['created_at'] as String? ?? '';
        }
      }
    } catch (_) {}

    // 2. Activation codes used
    try {
      final codes = await _client
          .from('activation_codes')
          .select('used_by, used_by_student_id, used_at')
          .eq('teacher_id', teacherId)
          .eq('is_used', true);
      for (final c in codes) {
        final sId = (c['used_by_student_id'] ?? c['used_by']) as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap.putIfAbsent(sId, () => 'active');
          dateMap.putIfAbsent(sId, () => c['used_at'] as String? ?? '');
        }
      }
    } catch (_) {}

    // 3. Exam submissions
    try {
      final examsData = await _client
          .from('exam_submissions')
          .select('student_id, submitted_at, exams!inner(teacher_id)')
          .eq('exams.teacher_id', teacherId);
      for (final item in examsData) {
        final sId = item['student_id'] as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap.putIfAbsent(sId, () => 'active');
          dateMap.putIfAbsent(
              sId, () => item['submitted_at'] as String? ?? '');
        }
      }
    } catch (_) {}

    // 4. Lesson progress fallback
    try {
      final progData = await _client
          .from('lesson_progress')
          .select('student_id, last_watched_at, lessons!inner(courses!inner(teacher_id))')
          .eq('lessons.courses.teacher_id', teacherId);
      for (final item in progData) {
        final sId = item['student_id'] as String?;
        if (sId != null && sId.isNotEmpty) {
          ids.add(sId);
          statusMap.putIfAbsent(sId, () => 'active');
          dateMap.putIfAbsent(
              sId, () => item['last_watched_at'] as String? ?? '');
        }
      }
    } catch (_) {}
  }

  /// Builds the enriched student list with progress info and grade level.
  Future<ApiResult<List<Map<String, dynamic>>>> buildStudentsResult(
    String teacherId,
    List<String> studentIds,
    Map<String, String> statusMap,
    Map<String, String> dateMap,
  ) async {
    final studentGradesMap = <String, String>{};
    final studentParentPhoneMap = <String, String>{};
    List<Map<String, dynamic>> studentsData = [];

    // 1. Query students table
    try {
      studentsData = await _client
          .from('students')
          .select('id, grade_level, parent_phone, created_at')
          .inFilter('id', studentIds);
      for (final s in studentsData) {
        final sid = s['id'] as String? ?? '';
        final g = s['grade_level'] as String? ?? '';
        final pp = s['parent_phone'] as String? ?? '';
        if (sid.isNotEmpty) {
          if (g.isNotEmpty) studentGradesMap[sid] = g;
          if (pp.isNotEmpty) studentParentPhoneMap[sid] = pp;
        }
      }
    } catch (_) {}

    // 2. Infer grade from student's enrolled courses if missing
    try {
      final subCourses = await _client
          .from('subscriptions')
          .select('student_id, courses(stage)')
          .inFilter('student_id', studentIds);
      for (final sc in subCourses) {
        final sid = sc['student_id'] as String? ?? '';
        final courseMap = sc['courses'] as Map<String, dynamic>?;
        final stage = courseMap?['stage'] as String? ?? '';
        if (sid.isNotEmpty && stage.isNotEmpty && !studentGradesMap.containsKey(sid)) {
          studentGradesMap[sid] = stage;
        }
      }
    } catch (_) {}

    try {
      final actCodes = await _client
          .from('activation_codes')
          .select('used_by, used_by_student_id, courses(stage)')
          .or('used_by.in.(${studentIds.join(",")}),used_by_student_id.in.(${studentIds.join(",")})');
      for (final ac in actCodes) {
        final sid = (ac['used_by_student_id'] ?? ac['used_by']) as String? ?? '';
        final courseMap = ac['courses'] as Map<String, dynamic>?;
        final stage = courseMap?['stage'] as String? ?? '';
        if (sid.isNotEmpty && stage.isNotEmpty && !studentGradesMap.containsKey(sid)) {
          studentGradesMap[sid] = stage;
        }
      }
    } catch (_) {}

    final progressMap = <String, int>{};
    int teacherLessonsCount = 0;
    String teacherDefaultStage = '';

    try {
      var teacherCourses = await _client
          .from('courses').select('id, stage').eq('teacher_id', teacherId);
      if (teacherCourses.isEmpty) {
        try {
          final tRow = await _client
              .from('teachers')
              .select('id, stage')
              .or('id.eq.$teacherId,user_id.eq.$teacherId')
              .maybeSingle();
          final actualTid = tRow?['id'] as String?;
          if (tRow?['stage'] != null) {
            teacherDefaultStage = tRow!['stage'].toString();
          }
          if (actualTid != null && actualTid != teacherId) {
            teacherCourses = await _client
                .from('courses').select('id, stage').eq('teacher_id', actualTid);
          }
        } catch (_) {}
      }

      if (teacherCourses.isNotEmpty && teacherDefaultStage.isEmpty) {
        final firstStage = teacherCourses.first['stage'] as String?;
        if (firstStage != null && firstStage.isNotEmpty) {
          teacherDefaultStage = firstStage;
        }
      }

      final courseIds = teacherCourses
          .map((c) => c['id'] as String?).whereType<String>().toList();
      if (courseIds.isNotEmpty) {
        final tLessons = await _client
            .from('lessons').select('id').inFilter('course_id', courseIds);
        teacherLessonsCount = tLessons.length;
        final lessonIds = tLessons
            .map((l) => l['id'] as String?).whereType<String>().toList();
        if (lessonIds.isNotEmpty && studentIds.isNotEmpty) {
          final progRows = await _client
              .from('lesson_progress')
              .select('student_id, is_completed, watched_seconds, view_count')
              .inFilter('student_id', studentIds)
              .inFilter('lesson_id', lessonIds);
          for (final p in progRows) {
            final sId = p['student_id'] as String? ?? '';
            final isDone = p['is_completed'] == true ||
                p['is_completed'] == 1 ||
                p['is_completed'] == 'true' ||
                (p['watched_seconds'] as num? ?? 0) > 0 ||
                (p['view_count'] as num? ?? 0) > 0;
            if (sId.isNotEmpty && isDone) {
              progressMap[sId] = (progressMap[sId] ?? 0) + 1;
            }
          }
        }
      }
    } catch (_) {}

    final usersData = await StudentUserLookup().forIds(studentIds);
    final studentsMap = {
      for (final s in studentsData)
        if (s['id'] != null) (s['id'] as String? ?? ''): s,
    };

    final result = <Map<String, dynamic>>[];
    for (final sid in studentIds) {
      final done = progressMap[sid] ?? 0;
      final total = teacherLessonsCount;
      final percent = total > 0 ? ((done / total) * 100).round() : 0;

      final sMeta = Map<String, dynamic>.from(studentsMap[sid] ?? {});
      final effectiveGrade = (sMeta['grade_level'] as String?)?.isNotEmpty == true
          ? sMeta['grade_level'] as String
          : studentGradesMap[sid] ?? teacherDefaultStage;
      sMeta['grade_level'] = effectiveGrade;

      final effectiveParentPhone = (sMeta['parent_phone'] as String?)?.isNotEmpty == true
          ? sMeta['parent_phone'] as String
          : studentParentPhoneMap[sid] ?? '';
      sMeta['parent_phone'] = effectiveParentPhone;

      result.add({
        'id': sid,
        'student_id': sid,
        'status': statusMap[sid] ?? 'active',
        'created_at': dateMap[sid] ?? '',
        'grade_level': effectiveGrade,
        'students': sMeta,
        'users': usersData[sid] ?? {},
        'completed_lessons': done,
        'total_lessons': total,
        'progress_percent': percent,
      });
    }
    return ApiResult.success(result);
  }
}
