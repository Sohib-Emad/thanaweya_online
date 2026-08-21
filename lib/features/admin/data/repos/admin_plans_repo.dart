import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminPlansRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches all subscription plans ordered by display_order.
  /// If the table is empty, it automatically seeds the 3 standard platform plans.
  Future<ApiResult<List<Map<String, dynamic>>>> getPlans() async {
    try {
      var data = await _client
          .from('subscription_plans')
          .select()
          .order('display_order', ascending: true);

      if (data.isEmpty) {
        // Seed default plans: monthly (1000), term (5000), yearly (10000)
        await _client.from('subscription_plans').insert([
          {
            'name': 'باقة شهرية',
            'billing_period': 'monthly',
            'price': 1000.0,
            'is_active': true,
            'display_order': 1,
          },
          {
            'name': 'باقة الترم الدراسي',
            'billing_period': 'term',
            'price': 5000.0,
            'is_active': true,
            'display_order': 2,
          },
          {
            'name': 'باقة سنوية (عرض خصم شهرين)',
            'billing_period': 'yearly',
            'price': 10000.0,
            'is_active': true,
            'display_order': 3,
          },
        ]);

        data = await _client
            .from('subscription_plans')
            .select()
            .order('display_order', ascending: true);
      }

      return ApiResult.success(List<Map<String, dynamic>>.from(data));
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
    int? displayOrder,
    bool isActive = true,
  }) async {
    try {
      await _client.from('subscription_plans').insert({
        'name': name,
        'billing_period': billingPeriod,
        'price': price,
        'max_students': maxStudents,
        'max_courses': maxCourses,
        'storage_limit_mb': storageLimitMb,
        'display_order': displayOrder ?? 0,
        'is_active': isActive,
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
    int? maxStudents,
    int? maxCourses,
    int? storageLimitMb,
    int? displayOrder,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name,
        'billing_period': billingPeriod,
        'price': price,
        if (maxStudents != null) 'max_students': maxStudents,
        if (maxCourses != null) 'max_courses': maxCourses,
        if (storageLimitMb != null) 'storage_limit_mb': storageLimitMb,
        if (displayOrder != null) 'display_order': displayOrder,
        if (isActive != null) 'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('subscription_plans')
          .update(updateData)
          .eq('id', planId);

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

  Future<ApiResult<void>> togglePlanStatus(String planId, bool isActive) async {
    try {
      await _client
          .from('subscription_plans')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
