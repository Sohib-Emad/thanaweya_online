import 'package:supabase_flutter/supabase_flutter.dart';

/// Subscription-checking helpers: subscriptions, activation codes, cross-ref.
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
        final tId = sub['teacher_id'] as String?;
        final cId = sub['course_id'] as String?;
        if (courseId != null && courseId.isNotEmpty && cId == courseId) {
          return true;
        }
        if (targetTeacherId != null &&
            targetTeacherId.isNotEmpty &&
            tId == targetTeacherId) return true;
        if (targetTeacherId == null && courseId == null) return true;
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
      final tId = code['teacher_id'] as String?;
      final cId = code['course_id'] as String?;
      if (courseId != null && courseId.isNotEmpty && cId == courseId) {
        return true;
      }
      if (targetTeacherId != null &&
          targetTeacherId.isNotEmpty &&
          tId == targetTeacherId) return true;
    }
    return null;
  }

  Future<bool?> crossReferenceTeacherSubscription(
    String uid,
    String courseId,
    String? targetTeacherId,
  ) async {
    final allTeacherIds = <String>{};
    try {
      final subs = await _client
          .from('subscriptions')
          .select('teacher_id')
          .eq('student_id', uid);
      for (final s in subs) {
        final tId = s['teacher_id'] as String?;
        if (tId != null && tId.isNotEmpty) allTeacherIds.add(tId);
      }
    } catch (_) {}
    try {
      final codes = await _client
          .from('activation_codes')
          .select('teacher_id')
          .or('used_by.eq.$uid,used_by_student_id.eq.$uid');
      for (final c in codes) {
        final tId = c['teacher_id'] as String?;
        if (tId != null && tId.isNotEmpty) allTeacherIds.add(tId);
      }
    } catch (_) {}
    if (allTeacherIds.isEmpty) return null;
    if (targetTeacherId != null &&
        allTeacherIds.contains(targetTeacherId)) return true;
    try {
      final match = await _client
          .from('courses')
          .select('id')
          .eq('id', courseId)
          .inFilter('teacher_id', allTeacherIds.toList())
          .limit(1);
      if (match.isNotEmpty) return true;
    } catch (_) {}
    return null;
  }
}
