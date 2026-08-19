import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_exam_grades_repo.dart';

/// Messaging, grades, and profile operations extracted from [TeacherStudentsRepo].
class TeacherStudentsCommunicationsRepo {
  final SupabaseClient _client = Supabase.instance.client;
  final TeacherStudentsExamGradesRepo examGrades =
      TeacherStudentsExamGradesRepo();

  /// Broadcasts a message to all of the teacher's subscribed students.
  Future<ApiResult<Map<String, dynamic>>> sendMessageToStudents({
    required String title,
    required String body,
  }) async {
    try {
      final data = await _client.rpc('send_teacher_message', params: {
        'p_title': title,
        'p_body': body,
      });
      return ApiResult.success(
        (data as Map<String, dynamic>?) ?? <String, dynamic>{},
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches full student profile details.
  Future<ApiResult<Map<String, dynamic>>> getStudentProfile(
    String studentId,
  ) async {
    try {
      Map<String, dynamic>? userRow;
      try {
        userRow = await _client
            .from('users')
            .select('id, full_name, email, phone, avatar_url')
            .eq('id', studentId)
            .maybeSingle();
      } catch (_) {}

      Map<String, dynamic>? studentRow;
      try {
        studentRow = await _client
            .from('students')
            .select('id, grade_level, parent_phone, created_at')
            .eq('id', studentId)
            .maybeSingle();
      } catch (_) {}

      return ApiResult.success({
        'id': studentId,
        'full_name': userRow?['full_name'] as String? ?? '',
        'email': userRow?['email'] as String? ?? '',
        'phone': userRow?['phone'] as String? ?? '',
        'avatar_url': userRow?['avatar_url'] as String? ?? '',
        'grade_level': studentRow?['grade_level'] as String? ?? '',
        'parent_phone': studentRow?['parent_phone'] as String? ?? '',
        'created_at': studentRow?['created_at'] as String? ?? '',
      });
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches subscription records for a student under this teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getStudentSubscriptions(
    String teacherId,
    String studentId,
  ) async {
    try {
      final data = await _client
          .from('subscriptions')
          .select('id, status, starts_at, expires_at, created_at')
          .eq('teacher_id', teacherId)
          .eq('student_id', studentId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
