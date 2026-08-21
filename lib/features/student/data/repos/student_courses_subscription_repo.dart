import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_subscription_helpers.dart';

/// Subscription-checking logic extracted from [StudentCoursesRepo].
class StudentCoursesSubscriptionRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final StudentCoursesSubscriptionHelpers _helpers =
      StudentCoursesSubscriptionHelpers();

  /// Checks if a student is subscribed to a course or teacher.
  Future<ApiResult<bool>> checkIsSubscribed({
    required String studentId,
    String? courseId,
    String? teacherId,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id ??
          _client.auth.currentSession?.user.id ??
          studentId;
      if (uid.isEmpty) return const ApiResult.success(false);

      String? targetTeacherId = teacherId;

      if (courseId != null && courseId.isNotEmpty) {
        final courseCheck = await _checkCourseAccess(uid, courseId);
        if (courseCheck != null) return ApiResult.success(courseCheck);
        targetTeacherId ??= await _resolveCourseTeacher(courseId);
      }

      final subResult = await _helpers.checkSubscriptions(uid, courseId, targetTeacherId);
      if (subResult != null) return ApiResult.success(subResult);

      final codeResult =
          await _helpers.checkActivationCodes(uid, courseId, targetTeacherId);
      if (codeResult != null) return ApiResult.success(codeResult);

      if (courseId != null && courseId.isNotEmpty) {
        final crossResult = await _helpers.crossReferenceTeacherSubscription(
          uid, courseId, targetTeacherId,
        );
        if (crossResult != null) return ApiResult.success(crossResult);
      }

      return const ApiResult.success(false);
    } catch (_) {
      return const ApiResult.success(false);
    }
  }

  Future<bool?> _checkCourseAccess(String uid, String courseId) async {
    try {
      final courseRows = await _client
          .from('courses')
          .select('id, teacher_id, price')
          .eq('id', courseId)
          .limit(1);
      if (courseRows.isEmpty) return null;
      final price = (courseRows.first['price'] as num?)?.toDouble() ?? 0.0;
      if (price == 0.0) return true;
    } catch (_) {}

    try {
      final payRes = await _client
          .from('payments')
          .select('id, status, course_id')
          .or('payer_id.eq.$uid,user_id.eq.$uid');
      for (final p in (payRes as List)) {
        final s = (p['status'] as String?)?.toLowerCase();
        if (s != 'success' && s != 'completed') continue;
        if (p['course_id'] == courseId) return true;
      }
    } catch (_) {
      try {
        final payRes = await _client
            .from('payments')
            .select('id, status, course_id')
            .eq('payer_id', uid);
        for (final p in (payRes as List)) {
          final s = (p['status'] as String?)?.toLowerCase();
          if (s != 'success' && s != 'completed') continue;
          if (p['course_id'] == courseId) return true;
        }
      } catch (_) {}
    }

    try {
      final enRes = await _client
          .from('course_enrollments')
          .select('id')
          .eq('student_id', uid)
          .eq('course_id', courseId)
          .limit(1);
      if (enRes.isNotEmpty) return true;
    } catch (_) {}

    try {
      final prog = await _client
          .from('lesson_progress')
          .select('lesson_id')
          .eq('student_id', uid);
      final lIds = (prog as List)
          .map((e) => e['lesson_id'] as String?)
          .whereType<String>()
          .toList();
      if (lIds.isNotEmpty) {
        final match = await _client
            .from('lessons')
            .select('id')
            .eq('course_id', courseId)
            .inFilter('id', lIds)
            .limit(1);
        if (match.isNotEmpty) return true;
      }
    } catch (_) {}

    return null;
  }

  Future<String?> _resolveCourseTeacher(String courseId) async {
    try {
      final rows = await _client
          .from('courses')
          .select('teacher_id')
          .eq('id', courseId)
          .limit(1);
      if (rows.isNotEmpty) return rows.first['teacher_id'] as String?;
    } catch (_) {}
    return null;
  }
}
