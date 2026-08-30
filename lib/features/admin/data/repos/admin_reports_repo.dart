import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_reports_data.dart';
export 'admin_reports_data.dart';

class AdminReportsRepo {
  final SupabaseClient _client;

  AdminReportsRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  Future<ApiResult<AdminReportsData>> getPlatformReports() async {
    try {
      final studentsRes = await _client.from('students').select('id');
      final totalStudents = studentsRes.length;

      final teachersRes = await _client.from('teachers').select('id, approval_status, subscription_amount, subject_id, subjects(name_ar)');
      int approvedTeachers = 0, pendingTeachers = 0, rejectedTeachers = 0;
      double revenue = 0;
      final Map<String, int> subjectCounts = {};

      for (final t in teachersRes) {
        final status = t['approval_status'] as String? ?? 'pending';
        if (status == 'approved') approvedTeachers++;
        else if (status == 'rejected') rejectedTeachers++;
        else pendingTeachers++;

        final amount = t['subscription_amount'];
        if (amount is num) revenue += amount.toDouble();
        else if (amount is String) revenue += double.tryParse(amount) ?? 0.0;

        final subjectMap = t['subjects'] as Map<String, dynamic>?;
        final subjectName = subjectMap?['name_ar'] as String? ?? 'أخرى';
        subjectCounts[subjectName] = (subjectCounts[subjectName] ?? 0) + 1;
      }

      final coursesRes = await _client.from('courses').select('id, is_published');
      final totalCourses = coursesRes.length;
      final publishedCourses = coursesRes.where((c) => c['is_published'] == true).length;

      final lessonsRes = await _client.from('lessons').select('id');
      final examsRes = await _client.from('exams').select('id');

      int totalSubmissions = 0;
      try {
        final submissionsRes = await _client.from('exam_submissions').select('id');
        totalSubmissions = submissionsRes.length;
      } catch (_) {}

      int activeSubscriptions = 0;
      try {
        final subsRes = await _client.from('subscriptions').select('id, status').eq('status', 'active');
        activeSubscriptions = subsRes.length;
      } catch (_) {
        activeSubscriptions = approvedTeachers;
      }

      final subjectDistribution = subjectCounts.entries
          .map((e) => {'name': e.key, 'count': e.value})
          .toList()..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return ApiResult.success(AdminReportsData(
        totalStudents: totalStudents,
        totalTeachers: teachersRes.length,
        approvedTeachers: approvedTeachers,
        pendingTeachers: pendingTeachers,
        rejectedTeachers: rejectedTeachers,
        totalCourses: totalCourses,
        publishedCourses: publishedCourses,
        totalLessons: lessonsRes.length,
        totalExams: examsRes.length,
        totalSubmissions: totalSubmissions,
        activeSubscriptions: activeSubscriptions > 0 ? activeSubscriptions : approvedTeachers,
        estimatedRevenue: revenue,
        subjectDistribution: subjectDistribution,
      ));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
