import 'package:flutter/material.dart';
import 'package:thanaweya_online/features/admin/ui/reports/platform_reports_screen.dart';

import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/auth/ui/otp_screen.dart';
import '../../features/auth/ui/role_selection_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';
import '../../features/splash/ui/splash_screen.dart';
import '../../features/teacher/ui/onboarding/teacher_form_screen.dart';
import '../../features/teacher/ui/onboarding/pending_review_screen.dart';
import '../../features/teacher/ui/dashboard/teacher_home_screen.dart';
import '../../features/teacher/ui/courses/courses_list_screen.dart';
import '../../features/teacher/ui/courses/lessons_list_screen.dart';
import '../../features/teacher/ui/courses/add_lesson_screen.dart';
import '../../features/teacher/ui/exams/exams_list_screen.dart';
import '../../features/teacher/ui/exams/add_questions_screen.dart';
import '../../features/teacher/ui/exams/exam_results_screen.dart';
import '../../features/teacher/ui/students/students_list_screen.dart';
import '../../features/teacher/ui/students/student_detail_screen.dart';
import '../../features/student/ui/onboarding/subject_selection_screen.dart';
import '../../features/student/ui/onboarding/teacher_selection_screen.dart';
import '../../features/student/ui/onboarding/student_form_screen.dart';
import '../../features/student/ui/dashboard/student_home_screen.dart';
import '../../features/student/ui/courses/teacher_page_screen.dart';
import '../../features/student/ui/courses/course_filter_screen.dart';
import '../../features/student/ui/courses/course_details_screen.dart';
import '../../features/student/ui/courses/my_bookmarks_screen.dart';
import '../../features/student/ui/courses/course_curriculum_screen.dart';
import '../../features/student/ui/courses/course_certificate_screen.dart';
import '../../features/student/ui/courses/student_my_courses_list_screen.dart';
import '../../features/student/ui/transactions/student_transactions_screen.dart';
import '../../features/student/ui/transactions/e_receipt_screen.dart';
import '../../features/student/ui/profile/student_profile_tab.dart';
import '../../features/student/ui/profile/student_edit_profile_screen.dart';
import '../../features/student/ui/profile/student_notification_settings_screen.dart';
import '../../features/student/ui/profile/student_payment_options_screen.dart';
import '../../features/student/ui/profile/student_add_card_screen.dart';
import '../../features/student/ui/profile/student_change_password_screen.dart';
import '../../features/student/ui/profile/student_language_screen.dart';
import '../../features/student/ui/profile/student_terms_screen.dart';
import '../../features/student/ui/courses/course_reviews_screen.dart';
import '../../features/student/ui/courses/write_review_screen.dart';
import '../../features/student/ui/courses/payment_methods_screen.dart';
import '../../features/student/ui/courses/course_lessons_screen.dart';
import '../../features/student/ui/courses/video_player_screen.dart';
import '../../features/student/ui/exams/exams_list_screen.dart';
import '../../features/student/ui/exams/exam_start_screen.dart';
import '../../features/student/ui/exams/exam_taking_screen.dart';
import '../../features/student/ui/exams/exam_result_screen.dart';
import '../../features/student/ui/exams/grade_history_screen.dart';
import '../../features/student/ui/comments/lesson_comments_screen.dart';
import '../../features/admin/ui/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/ui/teachers/teacher_requests_screen.dart';
import '../../features/admin/ui/teachers/all_teachers_screen.dart';
import '../../features/admin/ui/subjects/manage_subjects_screen.dart';
import '../../features/admin/ui/plans/subscription_plans_screen.dart';
import '../../features/admin/ui/plans/edit_plan_screen.dart';
import '../../features/shared/ui/notifications_screen.dart';
import '../../features/shared/models/user_model.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String notifications = '/notifications';

  static String homeForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return adminDashboard;
      case UserRole.teacher:
        return teacherHome;
      case UserRole.student:
        return studentHome;
    }
  }

  // Teacher
  static const String teacherForm = '/teacher/form';
  static const String teacherPending = '/teacher/pending';
  static const String teacherHome = '/teacher/home';
  static const String teacherCourses = '/teacher/courses';
  static const String teacherLessons = '/teacher/lessons';
  static const String teacherAddLesson = '/teacher/courses/lessons/add';
  static const String teacherExams = '/teacher/exams';
  static const String teacherAddQuestion = '/teacher/exams/add-question';
  static const String teacherExamResults = '/teacher/exams/results';
  static const String teacherStudents = '/teacher/students';
  static const String teacherStudentDetail = '/teacher/student-detail';

  // Student
  static const String studentSubjects = '/student/subjects';
  static const String studentTeachers = '/student/teachers';
  static const String studentForm = '/student/form';
  static const String studentHome = '/student/home';
  static const String studentTeacherPage = '/student/teacher-page';
  static const String studentCourseLessons = '/student/course-lessons';
  static const String studentVideoPlayer = '/student/video-player';
  static const String studentExams = '/student/exams';
  static const String studentExamStart = '/student/exam-start';
  static const String studentExamTaking = '/student/exam-taking';
  static const String studentExamResult = '/student/exam-result';
  static const String studentGradeHistory = '/student/grade-history';
  static const String studentFilter = '/student/filter';
  static const String studentCourseDetails = '/student/course-details';
  static const String studentBookmarks = '/student/bookmarks';
  static const String studentCurriculum = '/student/curriculum';
  static const String studentCertificate = '/student/certificate';
  static const String studentMyCourses = '/student/my-courses';
  static const String studentTransactions = '/student/transactions';
  static const String studentEReceipt = '/student/e-receipt';
  static const String studentReviews = '/student/reviews';
  static const String studentWriteReview = '/student/write-review';
  static const String studentPaymentMethods = '/student/payment-methods';
  static const String studentComments = '/student/comments';
  static const String studentProfile = '/student/profile';
  static const String studentEditProfile = '/student/edit-profile';
  static const String studentNotificationSettings =
      '/student/notification-settings';
  static const String studentPaymentOptions = '/student/payment-options';
  static const String studentAddCard = '/student/add-card';
  static const String studentChangePassword = '/student/change-password';
  static const String studentLanguage = '/student/language';
  static const String studentTerms = '/student/terms';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminTeacherRequests = '/admin/teacher-requests';
  static const String adminAllTeachers = '/admin/all-teachers';
  static const String adminManageSubjects = '/admin/manage-subjects';
  static const String adminSubscriptionPlans = '/admin/subscription-plans';
  static const String adminEditPlan = '/admin/edit-plan';
  static const String adminPlatformReports = '/admin/platform-reports';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == studentFilter) {
      return _fadeRoute<CourseFilters>(
        settings,
        const CourseFilterScreen(),
      );
    }
    return _fadeRoute<dynamic>(settings, _buildPage(settings));
  }

  static Route<T> _fadeRoute<T>(RouteSettings settings, Widget page) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
    );
  }

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
        final email = settings.arguments as String? ?? '';
        return OtpScreen(email: email);
      case notifications:
        return const NotificationsScreen();
      case teacherForm:
        return const TeacherFormScreen();
      case teacherPending:
        return const PendingReviewScreen();
      case teacherHome:
        return const TeacherHomeScreen();
      case teacherCourses:
        return const CoursesListScreen();
      case teacherLessons:
        final courseId = settings.arguments as String? ?? '';
        return LessonsListScreen(courseId: courseId);
      case teacherAddLesson:
        final courseId = settings.arguments as String? ?? '';
        return AddLessonScreen(courseId: courseId);
      case teacherExams:
        return const ExamsListScreen();
      case teacherAddQuestion:
        final examId = settings.arguments as String? ?? '';
        return AddQuestionsScreen(examId: examId);
      case teacherExamResults:
        final resultsArgs =
            settings.arguments as Map<String, dynamic>? ?? {};
        return ExamResultsScreen(
          examId: resultsArgs['examId'] ?? '',
          examTitle: resultsArgs['examTitle'] ?? '',
        );
      case teacherStudents:
        return const StudentsListScreen();
      case teacherStudentDetail:
        final studentArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return StudentDetailScreen(
          studentId: studentArgs['studentId'] ?? '',
          name: studentArgs['name'] ?? '',
          grade: studentArgs['grade'] ?? '',
          email: studentArgs['email'] ?? '',
        );

      // Student
      case studentSubjects:
        return const SubjectSelectionScreen();
      case studentTeachers:
        return const TeacherSelectionScreen();
      case studentForm:
        return const StudentFormScreen();
      case studentHome:
        return const StudentHomeScreen();
      case studentTeacherPage:
        final teacherArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return TeacherPageScreen(
          teacherId: teacherArgs['teacherId'] ?? '',
          title: teacherArgs['title'] ?? '',
          avatarUrl: teacherArgs['avatarUrl'] as String?,
        );
      case studentCourseLessons:
        final courseId = settings.arguments as String? ?? '';
        return CourseLessonsScreen(courseId: courseId);
      case studentVideoPlayer:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return VideoPlayerScreen(
          lessonId: args['lessonId'] ?? '',
          videoUrl: args['videoUrl'] ?? '',
          title: args['title'] ?? '',
          courseId: args['courseId'] ?? '',
          description: args['description'] ?? '',
          videoSourceType: args['videoSourceType'] ?? 'youtube',
        );
      case studentExams:
        return const StudentExamsListScreen();
      case studentExamStart:
        final examArgs = settings.arguments as Map<String, dynamic>?;
        return ExamStartScreen(examData: examArgs);
      case studentExamTaking:
        final takingArgs = settings.arguments as Map<String, dynamic>? ?? {};
        return ExamTakingScreen(examId: takingArgs['examId'] as String? ?? '');
      case studentExamResult:
        return const ExamResultScreen();
      case studentGradeHistory:
        return const GradeHistoryScreen();
      case studentFilter:
        return const CourseFilterScreen();
      case studentCourseDetails:
        final courseId = settings.arguments as String? ?? '';
        return CourseDetailsScreen(courseId: courseId);
      case studentBookmarks:
        return const MyBookmarksScreen();
      case studentCurriculum:
        final courseId = settings.arguments as String? ?? '';
        return CourseCurriculumScreen(courseId: courseId);
      case studentCertificate:
        return const CourseCertificateScreen();
      case studentMyCourses:
        return const StudentMyCoursesListScreen();
      case studentTransactions:
        return const StudentTransactionsScreen(showBackButton: true);
      case studentEReceipt:
        final args = settings.arguments as Map<String, dynamic>?;
        return EReceiptScreen(transactionData: args);
      case studentReviews:
        final courseId = settings.arguments as String? ?? '';
        return CourseReviewsScreen(courseId: courseId);
      case studentWriteReview:
        final courseId = settings.arguments as String? ?? '';
        return WriteReviewScreen(courseId: courseId);
      case studentPaymentMethods:
        return const PaymentMethodsScreen();
      case studentComments:
        final lessonId = settings.arguments as String? ?? '';
        return LessonCommentsScreen(lessonId: lessonId);
      case studentProfile:
        return const StudentProfileTab(isTabMode: false);
      case studentEditProfile:
        return const StudentEditProfileScreen();
      case studentNotificationSettings:
        return const StudentNotificationSettingsScreen();
      case studentPaymentOptions:
        return const StudentPaymentOptionsScreen();
      case studentAddCard:
        return const StudentAddCardScreen();
      case studentChangePassword:
        return const StudentChangePasswordScreen();
      case studentLanguage:
        return const StudentLanguageScreen();
      case studentTerms:
        return const StudentTermsScreen();

      // Admin
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
        return const LoginScreen();
    }
  }
}
