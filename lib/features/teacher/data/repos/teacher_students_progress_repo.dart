import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_progress_detail_repo.dart';

/// Facade delegating to [TeacherStudentsProgressDetailRepo].
class TeacherStudentsProgressRepo {
  final TeacherStudentsProgressDetailRepo detail =
      TeacherStudentsProgressDetailRepo();

  final SupabaseClient _client = Supabase.instance.client;

  /// Returns all lesson_progress rows for the teacher's courses.
  Future<ApiResult<List<Map<String, dynamic>>>> getStudentProgress(
    String teacherId,
  ) async {
    try {
      final data = await _client.from('lesson_progress').select('''
            id, student_id, lesson_id, is_completed, watched_seconds,
            last_watched_at,
            lessons!inner(id, title, course_id,
              courses!inner(id, title, teacher_id))
          ''').eq('lessons.courses.teacher_id', teacherId);
      return ApiResult.success(data);
    } catch (_) {
      return const ApiResult.success([]);
    }
  }
}
