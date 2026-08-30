import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';

extension AdminActiveCodesRepoGenerator on AdminActiveCodesRepo {
  /// Batch generates [count] unique activation codes for the specified teacher and course with price.
  Future<ApiResult<List<Map<String, dynamic>>>> generateCodes({
    required String teacherId,
    String? courseId,
    required int count,
    required double price,
  }) async {
    try {
      final List<Map<String, dynamic>> rowsToInsert = [];
      final random = Random();
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

      for (int i = 0; i < count; i++) {
        final part1 = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
        final part2 = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
        final code = 'TH-$part1-$part2';

        final row = <String, dynamic>{
          'teacher_id': teacherId,
          'code': code,
          'is_used': false,
          'price': price,
        };
        if (courseId != null && courseId.isNotEmpty) {
          row['course_id'] = courseId;
        }
        rowsToInsert.add(row);
      }

      final inserted = await client.from('activation_codes').insert(rowsToInsert).select('''
            id, teacher_id, course_id, code, is_used, price, created_at,
            courses(id, title, price)
          ''');

      return ApiResult.success(List<Map<String, dynamic>>.from(inserted));
    } catch (e) {
      debugPrint('[AdminActiveCodesRepo] generateCodes error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
