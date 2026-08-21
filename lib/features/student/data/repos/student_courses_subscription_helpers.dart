import 'package:supabase_flutter/supabase_flutter.dart';

/// Subscription-checking helpers: strictly per-course subscriptions, activation codes, and enrollments.
class StudentCoursesSubscriptionHelpers {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool?> checkSubscriptions(
    String uid,
    String? courseId,
    String? targetTeacherId,
  ) async {
    try {
      final subRes =
          await _client.from('subscriptions').select('*').eq('student_id', uid);
      for (final sub in subRes) {
        final status = (sub['status'] as String?)?.toLowerCase();
        if (status != 'active' && status != 'completed') continue;
        final expiresAtStr = sub['expires_at'] as String?;
        if (expiresAtStr != null) {
          final expiresAt = DateTime.tryParse(expiresAtStr);
          if (expiresAt != null && expiresAt.isBefore(DateTime.now())) continue;
        }
        final cId = sub['course_id'] as String?;
        final tId = sub['teacher_id'] as String?;

        // If checking a specific course, ONLY match that exact course_id
        if (courseId != null && courseId.isNotEmpty) {
          if (cId == courseId) return true;
        } else if (targetTeacherId != null && targetTeacherId.isNotEmpty) {
          if (tId == targetTeacherId) return true;
        } else {
          return true;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool?> checkActivationCodes(
    String uid,
    String? courseId,
    String? targetTeacherId,
  ) async {
    List<dynamic> codeRes = [];
    try {
      codeRes = await _client
          .from('activation_codes')
          .select('*')
          .or('used_by.eq.$uid,used_by_student_id.eq.$uid');
    } catch (_) {
      try {
        codeRes = await _client
            .from('activation_codes')
            .select('*')
            .eq('used_by', uid);
      } catch (_) {
        try {
          codeRes = await _client
              .from('activation_codes')
              .select('*')
              .eq('used_by_student_id', uid);
        } catch (_) {}
      }
    }
    for (final code in codeRes) {
      final expiresAtStr = code['expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.tryParse(expiresAtStr);
        if (expiresAt != null && expiresAt.isBefore(DateTime.now())) continue;
      }
      final cId = code['course_id'] as String?;
      final tId = code['teacher_id'] as String?;

      // If checking a specific course, ONLY match that exact course_id
      if (courseId != null && courseId.isNotEmpty) {
        if (cId == courseId) return true;
      } else if (targetTeacherId != null && targetTeacherId.isNotEmpty) {
        if (tId == targetTeacherId) return true;
      }
    }
    return null;
  }

  Future<bool?> crossReferenceTeacherSubscription(
    String uid,
    String courseId,
    String? targetTeacherId,
  ) async {
    try {
      // Check explicit enrollment for this exact course
      final enrollRes = await _client
          .from('course_enrollments')
          .select('id')
          .eq('student_id', uid)
          .eq('course_id', courseId)
          .limit(1);
      if (enrollRes.isNotEmpty) return true;
    } catch (_) {}
    return null;
  }
}
