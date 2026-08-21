import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';

class AdminStudentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches a lightweight list of all approved teachers for filtering.
  Future<ApiResult<List<Map<String, dynamic>>>> getTeachersForFilter() async {
    try {
      final data = await _client.from('teachers').select('''
            id, stage,
            users!inner(id, full_name, email),
            subjects(id, name_ar)
          ''').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getTeachersForFilter error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches all students with rich information, optionally filtered by teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getAllStudents({
    String? teacherId,
  }) async {
    try {
      Set<String>? filteredStudentIds;

      // If filtered by teacher, collect all student IDs associated with this teacher
      if (teacherId != null && teacherId.isNotEmpty) {
        filteredStudentIds = <String>{};

        // 1. From subscriptions
        try {
          final subData = await _client
              .from('subscriptions')
              .select('student_id')
              .eq('teacher_id', teacherId);
          for (final s in subData) {
            final sId = s['student_id'] as String?;
            if (sId != null && sId.isNotEmpty) filteredStudentIds.add(sId);
          }
        } catch (_) {}

        // 2. From used activation codes
        try {
          final codesData = await _client
              .from('activation_codes')
              .select('used_by, used_by_student_id')
              .eq('teacher_id', teacherId)
              .eq('is_used', true);
          for (final c in codesData) {
            final sId = (c['used_by_student_id'] ?? c['used_by']) as String?;
            if (sId != null && sId.isNotEmpty) filteredStudentIds.add(sId);
          }
        } catch (_) {}

        // 3. From exam submissions
        try {
          final examsData = await _client
              .from('exam_submissions')
              .select('student_id, exams!inner(teacher_id)')
              .eq('exams.teacher_id', teacherId);
          for (final item in examsData) {
            final sId = item['student_id'] as String?;
            if (sId != null && sId.isNotEmpty) filteredStudentIds.add(sId);
          }
        } catch (_) {}

        if (filteredStudentIds.isEmpty) {
          return const ApiResult.success([]);
        }
      }

      // Fetch students list
      var query = _client.from('students').select('''
            id, grade_level, parent_phone, created_at
          ''');

      if (filteredStudentIds != null) {
        query = query.inFilter('id', filteredStudentIds.toList());
      }

      final studentsData = await query.order('created_at', ascending: false);
      final studentIds = (studentsData as List)
          .map((s) => s['id'] as String?)
          .whereType<String>()
          .toList();

      if (studentIds.isEmpty) return const ApiResult.success([]);

      // Fetch user profile info
      final usersMap = await StudentUserLookup().forIds(studentIds);

      // Fetch subscriptions safely without assuming foreign key joins to courses
      List<dynamic> subscriptionsData = [];
      try {
        subscriptionsData = await _client
            .from('subscriptions')
            .select('id, student_id, teacher_id, status, created_at')
            .inFilter('student_id', studentIds);
      } catch (_) {}

      final studentSubsMap = <String, List<Map<String, dynamic>>>{};
      for (final sub in subscriptionsData) {
        final sid = sub['student_id'] as String? ?? '';
        if (sid.isNotEmpty) {
          studentSubsMap.putIfAbsent(sid, () => []).add(Map<String, dynamic>.from(sub as Map));
        }
      }

      final result = <Map<String, dynamic>>[];
      for (final st in studentsData) {
        final sid = st['id'] as String? ?? '';
        final user = usersMap[sid] ?? <String, dynamic>{};
        final subs = studentSubsMap[sid] ?? [];

        result.add({
          'id': sid,
          'student_id': sid,
          'grade_level': st['grade_level'] ?? 'first',
          'parent_phone': st['parent_phone'] ?? '',
          'created_at': st['created_at'] ?? '',
          'users': user,
          'subscriptions': subs,
        });
      }

      return ApiResult.success(result);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getAllStudents error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches all courses for a specific teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getCoursesForTeacher(
    String teacherId,
  ) async {
    try {
      final courses = await _client
          .from('courses')
          .select('id, teacher_id, title, description, cover_image_url, price, is_published, created_at')
          .eq('teacher_id', teacherId)
          .order('order', ascending: true);
      return ApiResult.success(List<Map<String, dynamic>>.from(courses));
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getCoursesForTeacher error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches courses with current student access status per course (active / locked / none).
  Future<ApiResult<List<Map<String, dynamic>>>> getStudentCoursesWithStatus({
    required String studentId,
    required String teacherId,
  }) async {
    try {
      final courses = await _client
          .from('courses')
          .select('id, teacher_id, title, description, cover_image_url, price, is_published')
          .eq('teacher_id', teacherId)
          .order('order', ascending: true);

      // 1. Fetch student subscriptions specifically matching course_id
      final subData = await _client
          .from('subscriptions')
          .select('id, course_id, status, starts_at, expires_at')
          .eq('student_id', studentId);

      final subByCourse = <String, Map<String, dynamic>>{};
      for (final s in (subData as List)) {
        final cid = s['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) {
          subByCourse[cid] = Map<String, dynamic>.from(s as Map);
        }
      }

      // 2. Fetch successful payments
      final payData = await _client
          .from('payments')
          .select('course_id, status')
          .eq('payer_id', studentId)
          .inFilter('status', ['success', 'completed']);

      final paidCourseIds = <String>{};
      for (final p in (payData as List)) {
        final cid = p['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) paidCourseIds.add(cid);
      }

      // 3. Fetch redeemed activation codes
      final codeData = await _client
          .from('activation_codes')
          .select('course_id')
          .or('used_by.eq.$studentId,used_by_student_id.eq.$studentId');

      final codeCourseIds = <String>{};
      for (final c in (codeData as List)) {
        final cid = c['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) codeCourseIds.add(cid);
      }

      final List<Map<String, dynamic>> enriched = [];
      for (final c in courses) {
        final cid = c['id'] as String? ?? '';
        final sub = subByCourse[cid];
        final subStatus = (sub?['status'] as String?)?.toLowerCase();

        final isExplicitlyUnlocked = subStatus == 'active' ||
            subStatus == 'completed' ||
            paidCourseIds.contains(cid) ||
            codeCourseIds.contains(cid);

        enriched.add({
          ...c,
          'is_unlocked': isExplicitlyUnlocked,
          'subscription_id': sub?['id'],
          'subscription_status': subStatus ?? (isExplicitlyUnlocked ? 'active' : 'none'),
        });
      }

      return ApiResult.success(enriched);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getStudentCoursesWithStatus error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Opens / Unlocks a specific course for a student by creating or updating an active subscription.
  Future<ApiResult<void>> unlockCourse({
    required String studentId,
    required String teacherId,
    required String courseId,
  }) async {
    try {
      // Check existing subscription for this specific course
      final existing = await _client
          .from('subscriptions')
          .select('id, status')
          .eq('student_id', studentId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existing != null) {
        await _client.from('subscriptions').update({
          'status': 'active',
          'starts_at': DateTime.now().toIso8601String(),
          'expires_at': null,
        }).eq('id', existing['id']);
      } else {
        await _client.from('subscriptions').insert({
          'student_id': studentId,
          'teacher_id': teacherId,
          'course_id': courseId,
          'status': 'active',
          'starts_at': DateTime.now().toIso8601String(),
        });
      }

      return const ApiResult.success(null);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] unlockCourse error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Closes / Locks a specific course for a student by suspending the subscription.
  Future<ApiResult<void>> lockCourse({
    required String studentId,
    required String teacherId,
    required String courseId,
  }) async {
    try {
      // Update subscription to suspended specifically for this course
      await _client
          .from('subscriptions')
          .update({
            'status': 'suspended',
            'expires_at': DateTime.now().toIso8601String(),
          })
          .eq('student_id', studentId)
          .eq('course_id', courseId);

      return const ApiResult.success(null);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] lockCourse error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Grants bonus points to a student with a reason.
  Future<ApiResult<int>> grantStudentBonusPoints({
    required String studentId,
    required int points,
    String? reason,
  }) async {
    try {
      int currentBonus = 0;
      try {
        final data = await _client
            .from('students')
            .select('bonus_points')
            .eq('id', studentId)
            .maybeSingle();
        currentBonus = (data?['bonus_points'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      final newTotal = currentBonus + points;
      await _client
          .from('students')
          .update({'bonus_points': newTotal})
          .eq('id', studentId);

      return ApiResult.success(newTotal);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] grantStudentBonusPoints error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
