import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
export 'admin_plans_mutations_ext.dart';

class AdminPlansRepo {
  final SupabaseClient _client;

  AdminPlansRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  /// Fetches all subscription plans ordered by display_order.
  /// If the table is empty, it automatically seeds the 3 standard platform plans.
  Future<ApiResult<List<Map<String, dynamic>>>> getPlans() async {
    try {
      var data = await _client.from('subscription_plans').select().order('display_order', ascending: true);

      if (data.isEmpty) {
        await _client.from('subscription_plans').insert([
          {'name': 'باقة شهرية', 'billing_period': 'monthly', 'price': 1000.0, 'is_active': true, 'display_order': 1},
          {'name': 'باقة الترم الدراسي', 'billing_period': 'term', 'price': 5000.0, 'is_active': true, 'display_order': 2},
          {'name': 'باقة سنوية (عرض خصم شهرين)', 'billing_period': 'yearly', 'price': 10000.0, 'is_active': true, 'display_order': 3},
        ]);
        data = await _client.from('subscription_plans').select().order('display_order', ascending: true);
      }

      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
