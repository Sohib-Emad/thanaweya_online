import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Activation code redemption operations for students.
class ActivationCodeData {
  ActivationCodeData(this._client);
  final SupabaseClient _client;
  String? get _userId => _client.auth.currentUser?.id ?? _client.auth.currentSession?.user.id;

  /// Redeems a teacher-generated activation code.
  /// Returns the teacher_id of the activated subscription on success.
  Future<ApiResult<String?>> redeemActivationCode(
    String code, {String? courseId, String? teacherId}
  ) async {
    final cleanCode = code.trim().toUpperCase();
    final rawCode = code.trim();
    final noDashCode = cleanCode.replaceAll('-', '').replaceAll(' ', '');
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return ApiResult.failure('يجب تسجيل الدخول أولاً');
    }
    try {
      // 1. Try secure RPC
      try {
        final res = await _client.rpc('redeem_activation_code', params: {'p_code': cleanCode});
        final data = res as Map<String, dynamic>?;
        if (data?['ok'] == true) {
          final tId = (data?['teacher_id'] as String?) ?? teacherId;
          final cId = (data?['course_id'] as String?) ?? courseId;
          try {
            await _client.from('payments').insert({
              'payer_id': userId, 'payer_type': 'student_subscription',
              if (cId != null && cId.isNotEmpty) 'course_id': cId,
              'amount': (data?['course_price'] as num?)?.toDouble() ?? 0.0,
              'payment_gateway': 'activation_code',
              'gateway_transaction_id': 'CODE-$cleanCode', 'status': 'success',
            });
          } catch (_) {}
          return ApiResult.success(tId);
        }
      } catch (_) {}
      // 2. Direct fallback: search activation_codes table
      List<dynamic> codeRows = [];
      try { codeRows = await _client.from('activation_codes').select('*').eq('code', cleanCode).limit(1); } catch (_) {}
      if (codeRows.isEmpty) {
        try { codeRows = await _client.from('activation_codes').select('*').ilike('code', rawCode).limit(1); } catch (_) {}
      }
      if (codeRows.isEmpty && noDashCode != cleanCode) {
        try { codeRows = await _client.from('activation_codes').select('*').eq('code', noDashCode).limit(1); } catch (_) {}
      }
      if (codeRows.isEmpty) return ApiResult.failure('الكود غير صحيح أو غير موجود');
      final codeRow = codeRows.first as Map<String, dynamic>;
      final isUsed = codeRow['is_used'] as bool? ?? false;
      final usedBy = (codeRow['used_by'] as String?) ?? (codeRow['used_by_student_id'] as String?);
      if (isUsed && usedBy != null && usedBy.isNotEmpty && usedBy != userId) {
        return ApiResult.failure('هذا الكود مستخدم من قبل');
      }
      final targetTeacherId = (codeRow['teacher_id'] as String?) ?? teacherId ?? '';
      final targetCourseId = (codeRow['course_id'] as String?) ?? courseId;
      // Check expiration
      final expiresAtStr = codeRow['expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.tryParse(expiresAtStr);
        if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
          return ApiResult.failure('انتهت صلاحية هذا الكود');
        }
      }
      await _markCodeUsed(codeRow['id'], userId);
      await _activateSubscription(userId, targetTeacherId, targetCourseId, codeRow['id']);
      await _insertPayment(userId, targetCourseId, cleanCode);
      return ApiResult.success(targetTeacherId);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('code_not_found')) return ApiResult.failure('الكود غير صحيح أو غير موجود');
      if (msg.contains('code_already_used')) return ApiResult.failure('هذا الكود مستخدم من قبل');
      if (msg.contains('unauthorized')) return ApiResult.failure('يجب تسجيل الدخول أولاً');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<void> _markCodeUsed(dynamic codeId, String userId) async {
    final now = DateTime.now().toIso8601String();
    final attempts = [
      {'is_used': true, 'used_by': userId, 'used_by_student_id': userId, 'used_at': now},
      {'is_used': true, 'used_by': userId, 'used_at': now},
      {'is_used': true, 'used_by_student_id': userId, 'used_at': now},
      {'is_used': true},
    ];
    for (final fields in attempts) {
      try { await _client.from('activation_codes').update(fields).eq('id', codeId); return; } catch (_) {}
    }
  }

  Future<void> _activateSubscription(
    String userId, String teacherId, String? courseId, dynamic codeId,
  ) async {
    if (teacherId.isEmpty) return;
    final now = DateTime.now().toIso8601String();
    final expiry = DateTime.now().add(const Duration(days: 365)).toIso8601String();
    final payload = {
      'student_id': userId, 'teacher_id': teacherId,
      if (courseId != null && courseId.isNotEmpty) 'course_id': courseId,
      'status': 'active', 'starts_at': now, 'expires_at': expiry,
    };
    try {
      await _client.from('subscriptions').upsert({...payload, 'activation_code_id': codeId}, onConflict: 'student_id,teacher_id');
    } catch (_) {
      try { await _client.from('subscriptions').insert(payload); } catch (_) {}
    }
  }

  Future<void> _insertPayment(String userId, String? courseId, String code) async {
    try {
      await _client.from('payments').insert({
        'payer_id': userId, 'payer_type': 'student_subscription',
        if (courseId != null && courseId.isNotEmpty) 'course_id': courseId,
        'amount': 0.0, 'payment_gateway': 'activation_code',
        'gateway_transaction_id': 'CODE-$code', 'status': 'success',
      });
    } catch (_) {}
  }
}
