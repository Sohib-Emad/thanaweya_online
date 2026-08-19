import 'package:flutter/material.dart';

import '../../features/admin/ui/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/ui/teachers/teacher_requests_screen.dart';
import '../../features/admin/ui/teachers/all_teachers_screen.dart';
import '../../features/admin/ui/subjects/manage_subjects_screen.dart';
import '../../features/admin/ui/plans/subscription_plans_screen.dart';
import '../../features/admin/ui/plans/edit_plan_screen.dart';
import '../../features/admin/ui/reports/platform_reports_screen.dart';

/// Route name constants and page builder for admin feature routes.
class AdminRoutes {
  AdminRoutes._();

  // ─── Route Names ────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminTeacherRequests = '/admin/teacher-requests';
  static const String adminAllTeachers = '/admin/all-teachers';
  static const String adminManageSubjects = '/admin/manage-subjects';
  static const String adminSubscriptionPlans = '/admin/subscription-plans';
  static const String adminEditPlan = '/admin/edit-plan';
  static const String adminPlatformReports = '/admin/platform-reports';

  /// Builds the page widget for an admin route.
  /// Returns `null` if [settings.name] does not match any admin route.
  static Widget? build(RouteSettings settings) {
    switch (settings.name) {
      case adminDashboard:
        return const AdminDashboardScreen();
      case adminTeacherRequests:
        return const TeacherRequestsScreen();
      case adminAllTeachers:
        return const AllTeachersScreen();
      case adminManageSubjects:
        return const ManageSubjectsScreen();
      case adminSubscriptionPlans:
        return const SubscriptionPlansScreen();
      case adminEditPlan:
        return const EditPlanScreen();
      case adminPlatformReports:
        return const PlatformReportsScreen();
      default:
        return null;
    }
  }
}
