import 'package:flutter/material.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';

import '../../features/teacher/ui/onboarding/teacher_form_screen.dart';
import '../../features/teacher/ui/onboarding/pending_review_screen.dart';
import '../../features/teacher/ui/dashboard/teacher_home_screen.dart';
import '../../features/teacher/ui/courses/courses_list_screen.dart';
import '../../features/teacher/ui/courses/course_details_screen.dart'
    as teacher_course_details;
import '../../features/teacher/ui/courses/lessons_list_screen.dart';
import '../../features/teacher/ui/courses/add_lesson_screen.dart';
import '../../features/teacher/ui/exams/exams_list_screen.dart';
import '../../features/teacher/ui/exams/exam_builder_wizard.dart';
import '../../features/teacher/ui/exams/add_questions_screen.dart';
import '../../features/teacher/ui/exams/exam_results_screen.dart';
import '../../features/teacher/ui/students/students_list_screen.dart';
import '../../features/teacher/ui/students/student_detail_screen.dart';
import '../../features/teacher/ui/cards/teacher_cards_screen.dart';
import '../../features/teacher/ui/analytics/teacher_analytics_screen.dart';
import '../../features/teacher/ui/notifications/teacher_notifications_screen.dart';
import '../../features/teacher/ui/subscreens/teacher_attendance_screen.dart';
import '../../features/teacher/ui/subscreens/teacher_notes_screen.dart';
import '../../features/teacher/ui/subscreens/teacher_leave_screen.dart';
import '../../features/teacher/ui/subscreens/teacher_schedule_screen.dart';
import '../../features/teacher/ui/subscreens/teacher_homework_screen.dart';
import '../../features/teacher/ui/subscreens/teacher_messages_screen.dart';
import '../../features/teacher/ui/plans/teacher_subscription_plans_screen.dart';
import '../../features/teacher/ui/settings/teacher_settings_screen.dart';

/// Route name constants and page builder for teacher feature routes.
class TeacherRoutes {
  TeacherRoutes._();

  // ─── Route Names ────────────────────────────────────────────────────────
  static const String teacherForm = '/teacher/form';
  static const String teacherPending = '/teacher/pending';
  static const String teacherHome = '/teacher/home';
  static const String teacherCourses = '/teacher/courses';
  static const String teacherCourseDetails = '/teacher/course-details';
  static const String teacherLessons = '/teacher/lessons';
  static const String teacherAddLesson = '/teacher/courses/lessons/add';
  static const String teacherExams = '/teacher/exams';
  static const String teacherExamBuilder = '/teacher/exam-builder';
  static const String teacherAddQuestion = '/teacher/exams/add-question';
  static const String teacherExamResults = '/teacher/exams/results';
  static const String teacherStudents = '/teacher/students';
  static const String teacherStudentDetail = '/teacher/student-detail';
  static const String teacherCards = '/teacher/cards';
  static const String teacherAnalytics = '/teacher/analytics';
  static const String teacherNotifications = '/teacher/notifications';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherNotes = '/teacher/notes';
  static const String teacherLeave = '/teacher/leave';
  static const String teacherSchedule = '/teacher/schedule';
  static const String teacherHomework = '/teacher/homework';
  static const String teacherMessages = '/teacher/messages';
  static const String teacherPlans = '/teacher/plans';
  static const String teacherSettings = '/teacher/settings';

  /// Builds the page widget for a teacher route.
  /// Returns `null` if [settings.name] does not match any teacher route.
  static Widget? build(RouteSettings settings) {
    switch (settings.name) {
      case teacherForm:
        return const TeacherFormScreen();
      case teacherPending:
        return const PendingReviewScreen();
      case teacherHome:
        return const TeacherHomeScreen();
      case teacherCourses:
        return const CoursesListScreen();
      case teacherCourseDetails:
        final courseModel = settings.arguments as CourseModel;
        return teacher_course_details.CourseDetailsScreen(course: courseModel);
      case teacherLessons:
        final courseId = settings.arguments as String? ?? '';
        return LessonsListScreen(courseId: courseId);
      case teacherAddLesson:
        final courseId = settings.arguments as String? ?? '';
        return AddLessonScreen(courseId: courseId);
      case teacherExams:
        return const ExamsListScreen();
      case teacherExamBuilder:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return ExamBuilderWizard(
          examId: args['examId'] as String?,
          initialCourseId: args['courseId'] as String?,
        );
      case teacherAddQuestion:
        final examId = settings.arguments as String? ?? '';
        return AddQuestionsScreen(examId: examId);
      case teacherExamResults:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return ExamResultsScreen(
          examId: args['examId'] ?? '',
          examTitle: args['examTitle'] ?? '',
        );
      case teacherStudents:
        return const StudentsListScreen();
      case teacherStudentDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return StudentDetailScreen(
          studentId: args['studentId'] ?? '',
          name: args['name'] ?? '',
          grade: args['grade'] ?? '',
          email: args['email'] ?? '',
        );
      case teacherCards:
        return const TeacherCardsScreen();
      case teacherAnalytics:
        return const TeacherAnalyticsScreen();
      case teacherNotifications:
        return const TeacherNotificationsScreen();
      case teacherAttendance:
        return const TeacherAttendanceScreen();
      case teacherNotes:
        return const TeacherNotesScreen();
      case teacherLeave:
        return const TeacherLeaveScreen();
      case teacherSchedule:
        return const TeacherScheduleScreen();
      case teacherHomework:
        return const TeacherHomeworkScreen();
      case teacherMessages:
        return const TeacherMessagesScreen();
      case teacherPlans:
        return const TeacherSubscriptionPlansScreen();
      case teacherSettings:
        return const TeacherSettingsScreen();
      default:
        return null;
    }
  }
}
