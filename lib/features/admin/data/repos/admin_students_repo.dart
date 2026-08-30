import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
export 'admin_students_query_ext.dart';
export 'admin_students_courses_ext.dart';
export 'admin_students_actions_ext.dart';

class AdminStudentsRepo {
  final SupabaseClient _client;

  AdminStudentsRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  /// Fetches a lightweight list of all approved teachers for filtering.
  Future<ApiResult<List<Map<String, dynamic>>>> getTeachersForFilter() async {
    try {
      final data = await _client
          .from('teachers')
          .select('''
            id, stage,
            users!inner(id, full_name, email),
            subjects(id, name_ar)
          ''')
          .order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getTeachersForFilter error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
