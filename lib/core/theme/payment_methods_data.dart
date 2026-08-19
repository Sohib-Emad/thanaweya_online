import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Payment methods CRUD operations for student accounts.
class PaymentMethodsData {
  PaymentMethodsData(this._client);

  final SupabaseClient _client;

  /// Fetches all payment methods for a student, ordered by default then date.
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

  /// Adds a new payment card, optionally setting it as the default.
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

  /// Deletes a payment method by its ID.
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

  /// Sets a payment method as the default, clearing others.
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
}
