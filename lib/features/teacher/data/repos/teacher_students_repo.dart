import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/user_lookup.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_communications_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_progress_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_list_builder.dart';

/// Facade that delegates to specialised sub-repos.
class TeacherStudentsRepo {
  final TeacherStudentsProgressRepo progress =
      TeacherStudentsProgressRepo();
  final TeacherStudentsCommunicationsRepo communications =
      TeacherStudentsCommunicationsRepo();
  final TeacherStudentsListBuilder _listBuilder = TeacherStudentsListBuilder();

  /// Fetches all students associated with this teacher.
  Future<ApiResult<List<Map<String, dynamic>>>> getStudents(
    String teacherId,
  ) async {
    try {
      final studentIdSet = <String>{};
      final studentSubStatus = <String, String>{};
      final studentCreatedDates = <String, String>{};
      await _listBuilder.collectStudentIds(
        teacherId, studentIdSet, studentSubStatus, studentCreatedDates,
      );
      if (studentIdSet.isEmpty) return const ApiResult.success([]);
      return await _listBuilder.buildStudentsResult(
        teacherId, studentIdSet.toList(),
        studentSubStatus, studentCreatedDates,
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Fetches basic student detail.
  Future<ApiResult<Map<String, dynamic>>> getStudentDetail(
    String studentId,
  ) async {
    try {
      final data = await Supabase.instance.client
          .from('students')
          .select('id, grade_level, parent_phone, created_at')
          .eq('id', studentId)
          .single();
      final users = await StudentUserLookup().forIds([studentId]);
      final user = users[studentId] ?? <String, dynamic>{};
      return ApiResult.success({...data, 'users': user});
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
