import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminPlansRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getPlans() async {
    try {
      final data = await _client
          .from('subscription_plans')
          .select()
          .order('display_order');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> addPlan({
    required String name,
    required String billingPeriod,
    required double price,
    int? maxStudents,
    int? maxCourses,
    int? storageLimitMb,
  }) async {
    try {
      await _client.from('subscription_plans').insert({
        'name': name,
        'billing_period': billingPeriod,
        'price': price,
        'max_students': maxStudents,
        'max_courses': maxCourses,
        'storage_limit_mb': storageLimitMb,
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updatePlan({
    required String planId,
    required String name,
    required String billingPeriod,
    required double price,
    bool? isActive,
  }) async {
    try {
      await _client.from('subscription_plans').update({
        'name': name,
        'billing_period': billingPeriod,
        'price': price,
        if (isActive != null) 'is_active': isActive,
      }).eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deletePlan(String planId) async {
    try {
      await _client.from('subscription_plans').delete().eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> togglePlanStatus(
      String planId, bool isActive) async {
    try {
      await _client
          .from('subscription_plans')
          .update({'is_active': isActive}).eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
