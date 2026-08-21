import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/theme/activation_code_data.dart';
import 'package:thanaweya_online/core/theme/payment_methods_data.dart';
import 'package:thanaweya_online/core/theme/subscriptions_data.dart';

/// Repository handling student payments, subscriptions, and activation codes.
class StudentPaymentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  PaymentMethodsData get _paymentMethods => PaymentMethodsData(_client);
  SubscriptionsData get _subscriptions => SubscriptionsData(_client);
  ActivationCodeData get _activationCode => ActivationCodeData(_client);

  /// Fetches all payment records for a user with plan/course details.
  Future<ApiResult<List<Map<String, dynamic>>>> getPayments(
    String userId,
  ) async {
    final uid = _client.auth.currentUser?.id ??
        _client.auth.currentSession?.user.id ??
        userId;
    if (uid.isEmpty) return const ApiResult.success([]);

    try {
      List<dynamic> rawPayments = [];

      // Try with joins first (payer_id)
      try {
        rawPayments = await _client
            .from('payments')
            .select('''

              id, payer_id, payer_type, course_id, plan_id, amount, payment_gateway,
              gateway_transaction_id, status, created_at,
              subscription_plans(id, name, price, billing_period),
              courses(id, title, price)
            ''')
            .eq('payer_id', uid)
            .order('created_at', ascending: false);
      } catch (_) {
        // Fallback: no joins
        try {
          rawPayments = await _client
              .from('payments')
              .select('id, payer_id, payer_type, course_id, plan_id, amount, payment_gateway, gateway_transaction_id, status, created_at')
              .eq('payer_id', uid)
              .order('created_at', ascending: false);
        } catch (_) {}
      }

      // Also try user_id column (some records may use it)
      if (rawPayments.isEmpty) {
        try {
          rawPayments = await _client
              .from('payments')
              .select('id, payer_id, payer_type, course_id, plan_id, amount, payment_gateway, gateway_transaction_id, status, created_at')
              .eq('user_id', uid)
              .order('created_at', ascending: false);
        } catch (_) {}
      }

      // Enrich course info if not already joined
      final needsEnrich = rawPayments.isNotEmpty &&
          rawPayments.first is Map &&
          !(rawPayments.first as Map).containsKey('courses');

      if (needsEnrich) {
        final courseIds = rawPayments
            .map((p) => p['course_id'] as String?)
            .whereType<String>()
            .toSet()
            .toList();

        final coursesMap = <String, Map<String, dynamic>>{};
        if (courseIds.isNotEmpty) {
          try {
            final cRows = await _client
                .from('courses')
                .select('id, title, price')
                .inFilter('id', courseIds);
            for (final c in cRows) {
              coursesMap[c['id'] as String? ?? ''] = Map<String, dynamic>.from(c as Map);
            }
          } catch (_) {}
        }

        rawPayments = rawPayments.map((p) {
          final cid = p['course_id'] as String? ?? '';
          return {
            ...(p as Map).cast<String, dynamic>(),
            if (coursesMap.containsKey(cid)) 'courses': coursesMap[cid],
          };
        }).toList();
      }

      return ApiResult.success(
        rawPayments.map((p) => Map<String, dynamic>.from(p as Map)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getPaymentMethods(
    String studentId,
  ) => _paymentMethods.getPaymentMethods(studentId);

  Future<ApiResult<void>> addPaymentMethod({
    required String studentId,
    required String cardHolder,
    required String cardLast4,
    String? cardBrand,
    int? expiryMonth,
    int? expiryYear,
    bool isDefault = false,
  }) => _paymentMethods.addPaymentMethod(
        studentId: studentId,
        cardHolder: cardHolder,
        cardLast4: cardLast4,
        cardBrand: cardBrand,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: isDefault,
      );

  Future<ApiResult<void>> deletePaymentMethod(
    String studentId,
    String methodId,
  ) => _paymentMethods.deletePaymentMethod(studentId, methodId);

  Future<ApiResult<void>> setDefaultPaymentMethod(
    String studentId,
    String methodId,
  ) => _paymentMethods.setDefaultPaymentMethod(studentId, methodId);

  Future<ApiResult<void>> subscribeWithPayment({
    required String teacherId,
    required double amount,
    String? courseId,
    String gateway = 'paymob',
  }) => _subscriptions.subscribeWithPayment(
        teacherId: teacherId,
        amount: amount,
        courseId: courseId,
        gateway: gateway,
      );

  Future<ApiResult<void>> subscribeFree({
    required String studentId,
    required String teacherId,
    String? courseId,
  }) => _subscriptions.subscribeFree(
        studentId: studentId,
        teacherId: teacherId,
        courseId: courseId,
      );

  Future<ApiResult<String?>> redeemActivationCode(
    String code, {
    String? courseId,
    String? teacherId,
  }) => _activationCode.redeemActivationCode(
        code,
        courseId: courseId,
        teacherId: teacherId,
      );
}
