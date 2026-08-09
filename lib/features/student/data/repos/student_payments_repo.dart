import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class StudentPaymentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getPayments(
    String userId,
  ) async {
    try {
      final data = await _client
          .from('payments')
          .select('''
            id, payer_id, payer_type, plan_id, amount, payment_gateway,
            gateway_transaction_id, status, created_at,
            subscription_plans(id, name, price, billing_period),
            courses(id, title, price)
          ''')
          .eq('payer_id', userId)
          .order('created_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getPaymentMethods(
    String studentId,
  ) async {
    try {
      final data = await _client
          .from('payment_methods')
          .select()
          .eq('student_id', studentId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> addPaymentMethod({
    required String studentId,
    required String cardHolder,
    required String cardLast4,
    String? cardBrand,
    int? expiryMonth,
    int? expiryYear,
    bool isDefault = false,
  }) async {
    try {
      if (isDefault) {
        await _client
            .from('payment_methods')
            .update({'is_default': false})
            .eq('student_id', studentId);
      }
      await _client.from('payment_methods').insert({
        'student_id': studentId,
        'card_holder': cardHolder,
        'card_last4': cardLast4,
        'card_brand': cardBrand,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'is_default': isDefault,
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deletePaymentMethod(
    String studentId,
    String methodId,
  ) async {
    try {
      await _client
          .from('payment_methods')
          .delete()
          .eq('id', methodId)
          .eq('student_id', studentId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> setDefaultPaymentMethod(
    String studentId,
    String methodId,
  ) async {
    try {
      await _client
          .from('payment_methods')
          .update({'is_default': false})
          .eq('student_id', studentId);
      await _client
          .from('payment_methods')
          .update({'is_default': true})
          .eq('id', methodId)
          .eq('student_id', studentId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Records a paid subscription atomically via RPC: creates/renews the
  /// student-teacher subscription AND inserts a successful payment record.
  /// The RPC uses auth.uid() for the payer, so no studentId is passed.
  Future<ApiResult<void>> subscribeWithPayment({
    required String teacherId,
    required double amount,
    String? courseId,
    String gateway = 'paymob',
  }) async {
    try {
      final res = await _client.rpc(
        'create_subscription_with_payment',
        params: {
          'p_teacher_id': teacherId,
          'p_amount': amount,
          'p_course_id': courseId,
          'p_gateway': gateway,
        },
      );
      final data = res as Map<String, dynamic>?;
      if (data?['ok'] == true) return const ApiResult.success(null);
      return ApiResult.failure('فشل تسجيل الاشتراك، حاول مرة أخرى');
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Subscribes to a free course (no payment record). Targets the
  /// UNIQUE(student_id, teacher_id) constraint so renewals update in place.
  Future<ApiResult<void>> subscribeFree({
    required String studentId,
    required String teacherId,
  }) async {
    try {
      await _client.from('subscriptions').upsert({
        'student_id': studentId,
        'teacher_id': teacherId,
        'status': 'active',
        'starts_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now()
            .add(const Duration(days: 365))
            .toIso8601String(),
      }, onConflict: 'student_id,teacher_id');
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Redeems a teacher-generated activation code through the secure RPC.
  /// Returns the teacher_id of the activated subscription on success.
  Future<ApiResult<String?>> redeemActivationCode(String code) async {
    try {
      final res = await _client.rpc(
        'redeem_activation_code',
        params: {'p_code': code.trim()},
      );
      final data = res as Map<String, dynamic>?;
      if (data?['ok'] == true) {
        final teacherId = data?['teacher_id'] as String?;
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          try {
            await _client.from('payments').insert({
              'payer_id': userId,
              'payer_type': 'student_subscription',
              'amount': 0.0,
              'payment_gateway': 'fawry',
              'gateway_transaction_id': 'CODE-${code.trim()}',
              'status': 'success',
            });
          } catch (e) {
            // Keep going so subscription activation is not blocked
            print('Error creating payment record for activation code: $e');
          }
        }
        return ApiResult.success(teacherId);
      }
      return ApiResult.failure('الكود غير صحيح أو غير متاح');
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('code_not_found')) {
        return ApiResult.failure('الكود غير صحيح أو غير موجود');
      }
      if (message.contains('code_already_used')) {
        return ApiResult.failure('هذا الكود مستخدم من قبل');
      }
      if (message.contains('unauthorized')) {
        return ApiResult.failure('يجب تسجيل الدخول أولاً');
      }
      return ApiErrorHandler.handleException(e);
    }
  }
}
