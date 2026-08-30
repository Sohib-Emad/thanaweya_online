import 'package:flutter/foundation.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

extension AdminStudentsRepoQuery on AdminStudentsRepo {
  /// Fetches all students with rich information, optionally filtered by teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getAllStudents({String? teacherId}) async {
    try {
      Set<String>? filteredStudentIds;
      if (teacherId != null && teacherId.isNotEmpty) {
        filteredStudentIds = await _fetchTeacherStudentIds(teacherId);
        if (filteredStudentIds.isEmpty) return const ApiResult.success([]);
      }

      var query = client.from('students').select('id, grade_level, parent_phone, created_at');
      if (filteredStudentIds != null) query = query.inFilter('id', filteredStudentIds.toList());

      final studentsData = await query.order('created_at', ascending: false);
      final studentIds = (studentsData as List).map((s) => s['id'] as String?).whereType<String>().toList();
      if (studentIds.isEmpty) return const ApiResult.success([]);

      final usersMap = await StudentUserLookup().forIds(studentIds);
      final studentSubsMap = await _fetchStudentSubscriptions(studentIds);

      final result = <Map<String, dynamic>>[];
      for (final st in studentsData) {
        final sid = st['id'] as String? ?? '';
        final user = usersMap[sid] ?? <String, dynamic>{};
        final subs = studentSubsMap[sid] ?? [];
        final plainPass = (user['plain_password'] as String?) ?? (st['plain_password'] as String?) ?? '';

        result.add({
          'id': sid,
          'student_id': sid,
          'grade_level': st['grade_level'] ?? 'first',
          'parent_phone': st['parent_phone'] ?? '',
          'created_at': st['created_at'] ?? '',
          'users': user,
          'plain_password': plainPass,
          'subscriptions': subs,
        });
      }
      return ApiResult.success(result);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getAllStudents error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<Set<String>> _fetchTeacherStudentIds(String teacherId) async {
    final ids = <String>{};
    try {
      final subs = await client.from('subscriptions').select('student_id').eq('teacher_id', teacherId);
      for (final s in subs) { if (s['student_id'] != null) ids.add(s['student_id'].toString()); }
    } catch (_) {}
    try {
      final codes = await client.from('activation_codes').select('used_by').eq('teacher_id', teacherId).eq('is_used', true);
      for (final c in codes) { if (c['used_by'] != null) ids.add(c['used_by'].toString()); }
    } catch (_) {}
    try {
      final exams = await client.from('exam_submissions').select('student_id, exams!inner(teacher_id)').eq('exams.teacher_id', teacherId);
      for (final item in exams) { if (item['student_id'] != null) ids.add(item['student_id'].toString()); }
    } catch (_) {}
    return ids;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchStudentSubscriptions(List<String> studentIds) async {
    final studentSubsMap = <String, List<Map<String, dynamic>>>{};
    try {
      final subscriptionsData = await client.from('subscriptions').select('id, student_id, teacher_id, status, created_at').inFilter('student_id', studentIds);
      for (final sub in subscriptionsData) {
        final sid = sub['student_id'] as String? ?? '';
        if (sid.isNotEmpty) studentSubsMap.putIfAbsent(sid, () => []).add(Map<String, dynamic>.from(sub as Map));
      }
    } catch (_) {}
    return studentSubsMap;
  }
}
