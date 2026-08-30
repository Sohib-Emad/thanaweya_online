import 'package:flutter/foundation.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

extension AdminStudentsRepoActions on AdminStudentsRepo {
  Future<ApiResult<void>> updateUserPassword(String userId, String newPassword, {String? email}) async {
    try {
      final res = await client.rpc('admin_set_user_password', params: {
        'p_user_id': userId,
        'p_new_password': newPassword,
        if (email != null && email.isNotEmpty) 'p_email': email,
      });
      final map = res as Map<String, dynamic>?;
      if (map?['ok'] == true) return const ApiResult.success(null);
      return ApiResult.failure(map?['error']?.toString() ?? 'تعذر تغيير كلمة المرور');
    } catch (_) {
      try {
        await client.from('users').update({'plain_password': newPassword}).eq('id', userId);
        await client.from('students').update({'plain_password': newPassword}).eq('id', userId);
        return const ApiResult.success(null);
      } catch (e) {
        return ApiErrorHandler.handleException(e);
      }
    }
  }

  Future<ApiResult<int>> grantStudentBonusPoints({required String studentId, required int points, String? reason}) async {
    try {
      int currentBonus = 0;
      try {
        final data = await client.from('students').select('bonus_points').eq('id', studentId).maybeSingle();
        currentBonus = (data?['bonus_points'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      final newTotal = currentBonus + points;
      await client.from('students').update({'bonus_points': newTotal}).eq('id', studentId);
      return ApiResult.success(newTotal);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] grantStudentBonusPoints error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
