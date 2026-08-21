import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Fetching teachers the student is subscribed to.
class StudentCoursesSubscribedTeachersRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches teachers the student is subscribed to.
  Future<ApiResult<List<Map<String, dynamic>>>> getSubscribedTeachers(
    String studentId,
  ) async {
    try {
      if (studentId.isEmpty) return const ApiResult.success([]);
      final teacherIdSet = <String>{};
      final subMap = <String, Map<String, dynamic>>{};
      await _collectSubscribedTeacherIds(studentId, teacherIdSet, subMap);
      if (teacherIdSet.isEmpty) return const ApiResult.success([]);
      return await _buildResult(teacherIdSet.toList(), subMap);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<void> _collectSubscribedTeacherIds(
    String studentId,
    Set<String> ids,
    Map<String, Map<String, dynamic>> subMap,
  ) async {
    try {
      final subData = await _client
          .from('subscriptions')
          .select('teacher_id, status, starts_at, expires_at')
          .eq('student_id', studentId)
          .eq('status', 'active');
      for (final sub in subData) {
        final tId = sub['teacher_id'] as String?;
        if (tId != null && tId.isNotEmpty) {
          ids.add(tId);
          subMap[tId] = sub;
        }
      }
    } catch (_) {}
    try {
      final codeData = await _client
          .from('activation_codes')
          .select('teacher_id, created_at, expires_at')
          .eq('used_by', studentId);
      _addCodeTeachers(codeData, ids, subMap);
    } catch (_) {}
  }

  void _addCodeTeachers(
    List<dynamic> codeData,
    Set<String> ids,
    Map<String, Map<String, dynamic>> subMap,
  ) {
    for (final code in codeData) {
      final tId = code['teacher_id'] as String?;
      if (tId != null && tId.isNotEmpty) {
        ids.add(tId);
        subMap.putIfAbsent(tId, () => {
          'teacher_id': tId,
          'status': 'active',
          'starts_at': code['created_at'],
          'expires_at': code['expires_at'],
        });
      }
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _buildResult(
    List<String> teacherIds,
    Map<String, Map<String, dynamic>> subMap,
  ) async {
    List<dynamic> teachersData = [];
    try {
      teachersData = await _client
          .from('teachers')
          .select('id, subject_id, stage, bio')
          .inFilter('id', teacherIds);
    } catch (_) {}
    List<dynamic> usersData = [];
    try {
      usersData = await _client
          .from('users')
          .select('id, full_name, avatar_url')
          .inFilter('id', teacherIds);
    } catch (_) {}
    final usersMap = {for (final u in usersData) (u['id'] ?? ''): u};
    final teachersMap = {for (final t in teachersData) (t['id'] ?? ''): t};
    final result = <Map<String, dynamic>>[];
    for (final tid in teacherIds) {
      final sub = subMap[tid] ?? {'teacher_id': tid, 'status': 'active'};
      result.add({
        ...sub,
        'teachers': {
          ...(teachersMap[tid] ?? {}),
          'users': usersMap[tid] ?? {},
        },
      });
    }
    return ApiResult.success(result);
  }
}
