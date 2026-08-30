import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';

extension AdminPlansRepoMutations on AdminPlansRepo {
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
      await client.from('subscription_plans').insert({
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
      await client.from('subscription_plans').update(updateData).eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deletePlan(String planId) async {
    try {
      await client.from('subscription_plans').delete().eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> togglePlanStatus(String planId, bool isActive) async {
    try {
      await client.from('subscription_plans').update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', planId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
