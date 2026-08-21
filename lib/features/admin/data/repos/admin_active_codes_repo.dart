import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminActiveCodesRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches all unused (active) activation codes, optionally filtered by teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getActiveCodes({
    String? teacherId,
    String? courseId,
  }) async {
    try {
      var query = _client.from('activation_codes').select('''
            id, teacher_id, course_id, code, is_used, created_at,
            teachers(id, users(full_name, email), subjects(name_ar)),
            courses(id, title)
          ''').eq('is_used', false);

      if (teacherId != null && teacherId.isNotEmpty) {
        query = query.eq('teacher_id', teacherId);
      }
      if (courseId != null && courseId.isNotEmpty) {
        query = query.eq('course_id', courseId);
      }

      final data = await query.order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('[AdminActiveCodesRepo] getActiveCodes error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Batch generates [count] unique activation codes for the specified teacher and course.
  Future<ApiResult<List<Map<String, dynamic>>>> generateCodes({
    required String teacherId,
    String? courseId,
    required int count,
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
        };
        if (courseId != null && courseId.isNotEmpty) {
          row['course_id'] = courseId;
        }
        rowsToInsert.add(row);
      }

      final inserted = await _client
          .from('activation_codes')
          .insert(rowsToInsert)
          .select('''
            id, teacher_id, course_id, code, is_used, created_at,
            courses(id, title)
          ''');

      return ApiResult.success(List<Map<String, dynamic>>.from(inserted));
    } catch (e) {
      debugPrint('[AdminActiveCodesRepo] generateCodes error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes an unused code by ID.
  Future<ApiResult<void>> deleteCode(String codeId) async {
    try {
      await _client
          .from('activation_codes')
          .delete()
          .eq('id', codeId)
          .eq('is_used', false);
      return const ApiResult.success(null);
    } catch (e) {
      debugPrint('[AdminActiveCodesRepo] deleteCode error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches teachers for the dropdown filter.
  Future<ApiResult<List<Map<String, dynamic>>>> getTeachers() async {
    try {
      final data = await _client.from('teachers').select('''
            id, users!inner(full_name, email), subjects(name_ar)
          ''').order('created_at', ascending: false);
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches courses for a specific teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getCourses(String teacherId) async {
    try {
      final data = await _client
          .from('courses')
          .select('id, title')
          .eq('teacher_id', teacherId)
          .order('title');
      return ApiResult.success(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
