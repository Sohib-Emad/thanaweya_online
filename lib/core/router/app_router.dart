import 'package:flutter/material.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';

import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/auth/ui/otp_screen.dart';
import '../../features/auth/ui/role_selection_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';
import '../../features/splash/ui/splash_screen.dart';
import '../../features/shared/ui/notifications_screen.dart';
import '../../features/shared/ui/maintenance_screen.dart';
import '../../features/shared/ui/force_update_screen.dart';
import '../../features/shared/ui/teacher_banned_screen.dart';
import '../../features/shared/ui/about_owner_screen.dart';
import '../../features/student/ui/courses/course_filter_screen.dart';
import '../../features/student/ui/courses/widgets/course_filters.dart';
import 'teacher_routes.dart';
import 'student_routes.dart';
import 'admin_routes.dart';

/// Central router that delegates page building to feature-specific routers.
class AppRouter {
  AppRouter._();

  // ─── Core Route Names ───────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String notifications = '/notifications';
  static const String maintenance = '/maintenance';
  static const String forceUpdate = '/force-update';
  static const String teacherBanned = '/teacher-banned';
  static const String aboutOwner = '/about-owner';

  // ─── Re-exported Feature Route Names ────────────────────────────────────
  // Teacher
  static const String teacherForm = TeacherRoutes.teacherForm;
  static const String teacherPending = TeacherRoutes.teacherPending;
  static const String teacherHome = TeacherRoutes.teacherHome;
  static const String teacherCourses = TeacherRoutes.teacherCourses;
  static const String teacherCourseDetails = TeacherRoutes.teacherCourseDetails;
  static const String teacherLessons = TeacherRoutes.teacherLessons;
  static const String teacherAddLesson = TeacherRoutes.teacherAddLesson;
  static const String teacherExams = TeacherRoutes.teacherExams;
  static const String teacherExamBuilder = TeacherRoutes.teacherExamBuilder;
  static const String teacherAddQuestion = TeacherRoutes.teacherAddQuestion;
  static const String teacherExamResults = TeacherRoutes.teacherExamResults;
  static const String teacherStudents = TeacherRoutes.teacherStudents;
  static const String teacherStudentDetail = TeacherRoutes.teacherStudentDetail;
  static const String teacherCards = TeacherRoutes.teacherCards;
  static const String teacherAnalytics = TeacherRoutes.teacherAnalytics;
  static const String teacherNotifications = TeacherRoutes.teacherNotifications;
  static const String teacherAttendance = TeacherRoutes.teacherAttendance;
  static const String teacherNotes = TeacherRoutes.teacherNotes;
  static const String teacherLeave = TeacherRoutes.teacherLeave;
  static const String teacherSchedule = TeacherRoutes.teacherSchedule;
  static const String teacherHomework = TeacherRoutes.teacherHomework;
  static const String teacherMessages = TeacherRoutes.teacherMessages;
  static const String teacherPlans = TeacherRoutes.teacherPlans;
  static const String teacherSettings = TeacherRoutes.teacherSettings;
  // Student
  static const String studentSubjects = StudentRoutes.studentSubjects;
  static const String studentTeachers = StudentRoutes.studentTeachers;
  static const String studentForm = StudentRoutes.studentForm;
  static const String studentHome = StudentRoutes.studentHome;
  static const String studentTeacherPage = StudentRoutes.studentTeacherPage;
  static const String studentCourseLessons = StudentRoutes.studentCourseLessons;
  static const String studentVideoPlayer = StudentRoutes.studentVideoPlayer;
  static const String studentExams = StudentRoutes.studentExams;
  static const String studentExamStart = StudentRoutes.studentExamStart;
  static const String studentExamTaking = StudentRoutes.studentExamTaking;
  static const String studentExamResult = StudentRoutes.studentExamResult;
  static const String studentExamAttempts = StudentRoutes.studentExamAttempts;
  static const String studentGradeHistory = StudentRoutes.studentGradeHistory;
  static const String studentFilter = StudentRoutes.studentFilter;
  static const String studentCourseDetails = StudentRoutes.studentCourseDetails;
  static const String studentBookmarks = StudentRoutes.studentBookmarks;
  static const String studentCurriculum = StudentRoutes.studentCurriculum;
  static const String studentCertificate = StudentRoutes.studentCertificate;
  static const String studentMyCourses = StudentRoutes.studentMyCourses;
  static const String studentTransactions = StudentRoutes.studentTransactions;
  static const String studentEReceipt = StudentRoutes.studentEReceipt;
  static const String studentReviews = StudentRoutes.studentReviews;
  static const String studentWriteReview = StudentRoutes.studentWriteReview;
  static const String studentPaymentMethods = StudentRoutes.studentPaymentMethods;
  static const String studentComments = StudentRoutes.studentComments;
  static const String studentProfile = StudentRoutes.studentProfile;
  static const String studentEditProfile = StudentRoutes.studentEditProfile;
  static const String studentNotificationSettings = StudentRoutes.studentNotificationSettings;
  static const String studentPaymentOptions = StudentRoutes.studentPaymentOptions;
  static const String studentAddCard = StudentRoutes.studentAddCard;
  static const String studentChangePassword = StudentRoutes.studentChangePassword;
  static const String studentLanguage = StudentRoutes.studentLanguage;
  static const String studentTerms = StudentRoutes.studentTerms;
  // Admin
  static const String adminDashboard = AdminRoutes.adminDashboard;
  static const String adminTeacherRequests = AdminRoutes.adminTeacherRequests;
  static const String adminAllTeachers = AdminRoutes.adminAllTeachers;
  static const String adminManageSubjects = AdminRoutes.adminManageSubjects;
  static const String adminSubscriptionPlans = AdminRoutes.adminSubscriptionPlans;
  static const String adminEditPlan = AdminRoutes.adminEditPlan;
  static const String adminPlatformReports = AdminRoutes.adminPlatformReports;
  static const String adminStudents = AdminRoutes.adminStudents;
  static const String adminActiveCodes = AdminRoutes.adminActiveCodes;
  static const String adminPushTokens = AdminRoutes.adminPushTokens;

  static String homeForRole(UserRole role) => switch (role) {
        UserRole.superAdmin => adminDashboard,
        UserRole.teacher => teacherHome,
        UserRole.student => studentHome,
      };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == studentFilter) {
      return _fadeRoute<CourseFilters>(settings, const CourseFilterScreen());
    }
    return _fadeRoute<dynamic>(settings, _buildPage(settings));
  }

  static Route<T> _fadeRoute<T>(RouteSettings settings, Widget page) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
      );

  static Widget _buildPage(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return const AnimatedSplashScreen();
      case onboarding:
        return const OnboardingScreen();
      case login:
        return const LoginScreen();
      case roleSelection:
        return const RoleSelectionScreen();
      case forgotPassword:
        return const ForgotPasswordScreen();
      case otp:
        return OtpScreen(email: settings.arguments as String? ?? '');
      case notifications:
        return const NotificationsScreen();
      case maintenance:
        return MaintenanceScreen(
            customMessage: settings.arguments as String?);
      case forceUpdate:
        return ForceUpdateScreen(
            customMessage: settings.arguments as String?);
      case teacherBanned:
        return TeacherBannedScreen(
            banReason: settings.arguments as String?);
      case aboutOwner:
        return const AboutOwnerScreen();
    }
    return TeacherRoutes.build(settings) ??
        StudentRoutes.build(settings) ??
        AdminRoutes.build(settings) ??
        const LoginScreen();
  }
}
