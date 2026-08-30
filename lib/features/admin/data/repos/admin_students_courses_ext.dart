import 'package:flutter/foundation.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

extension AdminStudentsRepoCourses on AdminStudentsRepo {
  Future<ApiResult<List<Map<String, dynamic>>>> getCoursesForTeacher(String teacherId) async {
    try {
      final courses = await client
          .from('courses')
          .select('id, teacher_id, title, description, cover_image_url, price, is_published, created_at')
          .eq('teacher_id', teacherId)
          .order('order', ascending: true);
      return ApiResult.success(List<Map<String, dynamic>>.from(courses));
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getCoursesForTeacher error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentCoursesWithStatus({
    required String studentId,
    required String teacherId,
  }) async {
    try {
      final courses = await client
          .from('courses')
          .select('id, teacher_id, title, description, cover_image_url, price, is_published')
          .eq('teacher_id', teacherId)
          .order('order', ascending: true);

      final subData = await client.from('subscriptions').select('id, course_id, status, starts_at, expires_at').eq('student_id', studentId);
      final subByCourse = <String, Map<String, dynamic>>{};
      for (final s in (subData as List)) {
        final cid = s['course_id'] as String?;
        if (cid != null && cid.isNotEmpty) subByCourse[cid] = Map<String, dynamic>.from(s as Map);
      }

      final payData = await client.from('payments').select('course_id, status').eq('payer_id', studentId).eq('status', 'success');
      final paidCourseIds = (payData as List).map((p) => p['course_id'] as String?).whereType<String>().toSet();

      final codeData = await client.from('activation_codes').select('course_id').eq('used_by', studentId);
      final codeCourseIds = (codeData as List).map((c) => c['course_id'] as String?).whereType<String>().toSet();

      final List<Map<String, dynamic>> enriched = [];
      for (final c in courses) {
        final cid = c['id'] as String? ?? '';
        final sub = subByCourse[cid];
        final subStatus = (sub?['status'] as String?)?.toLowerCase();
        final isExplicitlyUnlocked = subStatus == 'active' || subStatus == 'completed' || paidCourseIds.contains(cid) || codeCourseIds.contains(cid);

        enriched.add({
          ...c,
          'is_unlocked': isExplicitlyUnlocked,
          'subscription_id': sub?['id'],
          'subscription_status': subStatus ?? (isExplicitlyUnlocked ? 'active' : 'none'),
        });
      }
      return ApiResult.success(enriched);
    } catch (e) {
      debugPrint('[AdminStudentsRepo] getStudentCoursesWithStatus error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> unlockCourse({required String studentId, required String teacherId, required String courseId}) async {
    try {
      final existingCourseSub = await client.from('subscriptions').select('id, status').eq('student_id', studentId).eq('course_id', courseId).maybeSingle();
      if (existingCourseSub != null) {
        await client.from('subscriptions').update({'status': 'active', 'starts_at': DateTime.now().toIso8601String(), 'expires_at': null}).eq('id', existingCourseSub['id']);
      } else {
        final existingGeneralSub = await client.from('subscriptions').select('id, status').eq('student_id', studentId).eq('teacher_id', teacherId).isFilter('course_id', null).maybeSingle();
        if (existingGeneralSub != null) {
          await client.from('subscriptions').update({'course_id': courseId, 'status': 'active', 'starts_at': DateTime.now().toIso8601String(), 'expires_at': null}).eq('id', existingGeneralSub['id']);
        } else {
          await client.from('subscriptions').insert({'student_id': studentId, 'teacher_id': teacherId, 'course_id': courseId, 'status': 'active', 'starts_at': DateTime.now().toIso8601String()});
        }
      }
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> lockCourse({required String studentId, required String teacherId, required String courseId}) async {
    try {
      await client.from('subscriptions').update({'status': 'suspended', 'expires_at': DateTime.now().toIso8601String()}).eq('student_id', studentId).eq('course_id', courseId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
