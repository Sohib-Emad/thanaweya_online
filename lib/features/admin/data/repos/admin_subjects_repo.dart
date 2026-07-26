import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminSubjectsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getSubjects() async {
    try {
      final data = await _client
          .from('subjects')
          .select()
          .order('display_order');
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> addSubject({
    required String nameAr,
    required String nameEn,
    String? iconName,
  }) async {
    try {
      await _client.from('subjects').insert({
        'name_ar': nameAr,
        'name_en': nameEn,
        'icon_name': iconName,
      });
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> updateSubject({
    required String subjectId,
    required String nameAr,
    required String nameEn,
    String? iconName,
    bool? isActive,
  }) async {
    try {
      await _client.from('subjects').update({
        'name_ar': nameAr,
        'name_en': nameEn,
        if (iconName != null) 'icon_name': iconName,
        if (isActive != null) 'is_active': isActive,
      }).eq('id', subjectId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteSubject(String subjectId) async {
    try {
      await _client.from('subjects').delete().eq('id', subjectId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
