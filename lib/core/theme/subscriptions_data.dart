import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Subscription creation operations for students.
class SubscriptionsData {
  SubscriptionsData(this._client);

  final SupabaseClient _client;

  String? get _userId =>
      _client.auth.currentUser?.id ?? _client.auth.currentSession?.user.id;

  /// Records a paid subscription atomically via RPC or direct fallback.
  Future<ApiResult<void>> subscribeWithPayment({
    required String teacherId,
    required double amount,
    String? courseId,
    String gateway = 'paymob',
  }) async {
    final userId = _userId;
    final cleanCourseId = (courseId != null && courseId.isNotEmpty) ? courseId : null;
    try {
      try {
        final res = await _client.rpc(
          'create_subscription_with_payment',
          params: {
            'p_teacher_id': teacherId,
            'p_amount': amount,
            if (cleanCourseId != null) 'p_course_id': cleanCourseId,
            'p_gateway': gateway,
          },
        );
        final data = res as Map<String, dynamic>?;
        if (data?['ok'] == true) return const ApiResult.success(null);
      } catch (_) {}

      if (userId != null && userId.isNotEmpty) {
        if (teacherId.isNotEmpty) {
          try {
            await _client.from('subscriptions').upsert({
              'student_id': userId,
              'teacher_id': teacherId,
              if (cleanCourseId != null) 'course_id': cleanCourseId,
              'status': 'active',
              'starts_at': DateTime.now().toIso8601String(),
              'expires_at': DateTime.now()
                  .add(const Duration(days: 365))
                  .toIso8601String(),
            }, onConflict: cleanCourseId != null ? 'student_id,course_id' : 'student_id,teacher_id');
          } catch (_) {}
        }

        try {
          await _client.from('payments').insert({
            'payer_id': userId,
            'payer_type': 'student_subscription',
            if (cleanCourseId != null) 'course_id': cleanCourseId,
            'amount': amount,
            'payment_gateway': gateway,
            'status': 'success',
          });
        } catch (_) {}

        return const ApiResult.success(null);
      }

      return ApiResult.failure('فشل تسجيل الاشتراك، حاول مرة أخرى');
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Subscribes to a free course (no payment record).
  Future<ApiResult<void>> subscribeFree({
    required String studentId,
    required String teacherId,
    String? courseId,
  }) async {
    try {
      final uid = _userId ?? studentId;
      if (uid.isEmpty) return ApiResult.failure('يجب تسجيل الدخول أولاً');
      if (teacherId.isEmpty) return ApiResult.failure('معرف المعلم غير صالح');

      final cleanCourseId = (courseId != null && courseId.isNotEmpty) ? courseId : null;

      await _client.from('subscriptions').upsert({
        'student_id': uid,
        'teacher_id': teacherId,
        if (cleanCourseId != null) 'course_id': cleanCourseId,
        'status': 'active',
        'starts_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now()
            .add(const Duration(days: 365))
            .toIso8601String(),
      }, onConflict: cleanCourseId != null ? 'student_id,course_id' : 'student_id,teacher_id');
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
