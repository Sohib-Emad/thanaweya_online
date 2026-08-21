import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

class AdminReportsData {
  final int totalStudents;
  final int totalTeachers;
  final int approvedTeachers;
  final int pendingTeachers;
  final int rejectedTeachers;
  final int totalCourses;
  final int publishedCourses;
  final int totalLessons;
  final int totalExams;
  final int totalSubmissions;
  final int activeSubscriptions;
  final double estimatedRevenue;
  final List<Map<String, dynamic>> subjectDistribution;

  const AdminReportsData({
    required this.totalStudents,
    required this.totalTeachers,
    required this.approvedTeachers,
    required this.pendingTeachers,
    required this.rejectedTeachers,
    required this.totalCourses,
    required this.publishedCourses,
    required this.totalLessons,
    required this.totalExams,
    required this.totalSubmissions,
    required this.activeSubscriptions,
    required this.estimatedRevenue,
    required this.subjectDistribution,
  });

  int get totalUsers => totalStudents + totalTeachers;
}

class AdminReportsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ApiResult<AdminReportsData>> getPlatformReports() async {
    try {
      // 1. Users / Students
      final studentsRes = await _client.from('students').select('id');
      final totalStudents = studentsRes.length;

      // 2. Teachers by status
      final teachersRes = await _client
          .from('teachers')
          .select('id, approval_status, subscription_amount, subject_id, subjects(name_ar)');
      
      int approvedTeachers = 0;
      int pendingTeachers = 0;
      int rejectedTeachers = 0;
      double revenue = 0;
      final Map<String, int> subjectCounts = {};

      for (final t in teachersRes) {
        final status = t['approval_status'] as String? ?? 'pending';
        if (status == 'approved') {
          approvedTeachers++;
        } else if (status == 'rejected') {
          rejectedTeachers++;
        } else {
          pendingTeachers++;
        }

        final amount = t['subscription_amount'];
        if (amount != null) {
          if (amount is num) {
            revenue += amount.toDouble();
          } else if (amount is String) {
            revenue += double.tryParse(amount) ?? 0.0;
          }
        }

        final subjectMap = t['subjects'] as Map<String, dynamic>?;
        final subjectName = subjectMap?['name_ar'] as String? ?? 'أخرى';
        subjectCounts[subjectName] = (subjectCounts[subjectName] ?? 0) + 1;
      }

      final totalTeachers = teachersRes.length;

      // 3. Courses & Lessons
      final coursesRes = await _client.from('courses').select('id, is_published');
      final totalCourses = coursesRes.length;
      final publishedCourses = coursesRes.where((c) => c['is_published'] == true).length;

      final lessonsRes = await _client.from('lessons').select('id');
      final totalLessons = lessonsRes.length;

      // 4. Exams & Submissions
      final examsRes = await _client.from('exams').select('id');
      final totalExams = examsRes.length;

      int totalSubmissions = 0;
      try {
        final submissionsRes = await _client.from('exam_submissions').select('id');
        totalSubmissions = submissionsRes.length;
      } catch (_) {}

      // 5. Subscriptions
      int activeSubscriptions = 0;
      try {
        final subsRes = await _client.from('subscriptions').select('id, status').eq('status', 'active');
        activeSubscriptions = subsRes.length;
      } catch (_) {
        activeSubscriptions = approvedTeachers;
      }

      final subjectDistribution = subjectCounts.entries
          .map((e) => {'name': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return ApiResult.success(
        AdminReportsData(
          totalStudents: totalStudents,
          totalTeachers: totalTeachers,
          approvedTeachers: approvedTeachers,
          pendingTeachers: pendingTeachers,
          rejectedTeachers: rejectedTeachers,
          totalCourses: totalCourses,
          publishedCourses: publishedCourses,
          totalLessons: totalLessons,
          totalExams: totalExams,
          totalSubmissions: totalSubmissions,
          activeSubscriptions: activeSubscriptions > 0 ? activeSubscriptions : approvedTeachers,
          estimatedRevenue: revenue,
          subjectDistribution: subjectDistribution,
        ),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
