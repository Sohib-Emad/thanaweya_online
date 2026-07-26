import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/activation_code_model.dart';


class TeacherStudentsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<List<Map<String, dynamic>>>> getStudents(
      String teacherId) async {
    try {
      final data = await _client.from('subscriptions').select('''
            id, status, created_at,
            students!inner(id, grade_level, parent_phone, created_at),
            users!inner(id, full_name, email, phone)
          ''').eq('teacher_id', teacherId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getStudentDetail(
      String studentId) async {
    try {
      final data = await _client.from('students').select('''
            id, grade_level, parent_phone, created_at,
            users!inner(id, full_name, email, phone)
          ''').eq('id', studentId).single();
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<ActivationCodeModel>>> getActivationCodes(
      String teacherId) async {
    try {
      final data = await _client
          .from('activation_codes')
          .select()
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);
      return ApiResult.success(
        data.map((e) => ActivationCodeModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<ActivationCodeModel>>> generateCodes({
    required String teacherId,
    required int count,
    String? courseId,
  }) async {
    try {
      final codes = <Map<String, dynamic>>[];
      final random = Random();

      for (var i = 0; i < count; i++) {
        final code = List.generate(8, (_) => random.nextInt(10)).join();
        codes.add({
          'teacher_id': teacherId,
          'code': code,
          'course_id': courseId,
        });
      }

      final data = await _client
          .from('activation_codes')
          .insert(codes)
          .select();
      return ApiResult.success(
        data.map((e) => ActivationCodeModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> deleteCode(String codeId) async {
    try {
      await _client.from('activation_codes').delete().eq('id', codeId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentProgress(
      String teacherId) async {
    try {
      final data = await _client.from('lesson_progress').select('''
            id, student_id, lesson_id, is_completed, watched_seconds, last_watched_at,
            lessons!inner(id, title, course_id,
              courses!inner(id, title, teacher_id)
            )
          ''').eq('lessons.courses.teacher_id', teacherId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
