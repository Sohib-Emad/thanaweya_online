import 'package:flutter/material.dart';

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
import '../../features/student/ui/courses/course_reviews_screen.dart';
import '../../features/student/ui/courses/write_review_screen.dart';
import '../../features/student/ui/courses/payment_methods_screen.dart';
import '../../features/student/ui/courses/course_lessons_screen.dart';
import '../../features/student/ui/courses/video_player_screen.dart';
import '../../features/student/ui/exams/exams_list_screen.dart';
import '../../features/student/ui/exams/exam_start_screen.dart';
import '../../features/student/ui/exams/exam_taking_screen.dart';
import '../../features/student/ui/exams/exam_result_screen.dart';
import '../../features/student/ui/exams/exam_attempts_screen.dart';
import '../../features/student/ui/exams/grade_history_screen.dart';
import '../../features/student/ui/comments/lesson_comments_screen.dart';

/// Route names and page builder for student course & exam routes.
class StudentCourseRoutes {
  StudentCourseRoutes._();

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
  static const String studentExamAttempts = '/student/exam-attempts';
  static const String studentGradeHistory = '/student/grade-history';
  static const String studentFilter = '/student/filter';
  static const String studentCourseDetails = '/student/course-details';
  static const String studentBookmarks = '/student/bookmarks';
  static const String studentCurriculum = '/student/curriculum';
  static const String studentCertificate = '/student/certificate';
  static const String studentMyCourses = '/student/my-courses';
  static const String studentReviews = '/student/reviews';
  static const String studentWriteReview = '/student/write-review';
  static const String studentPaymentMethods = '/student/payment-methods';
  static const String studentComments = '/student/comments';

  static Widget? build(RouteSettings settings) {
    switch (settings.name) {
      case studentSubjects:
        return const SubjectSelectionScreen();
      case studentTeachers:
        return const TeacherSelectionScreen();
      case studentForm:
        return const StudentFormScreen();
      case studentHome:
        return const StudentHomeScreen();
      case studentTeacherPage:
        final a = settings.arguments as Map<String, dynamic>? ?? {};
        return TeacherPageScreen(
            teacherId: a['teacherId'] ?? '',
            title: a['title'] ?? '',
            avatarUrl: a['avatarUrl'] as String?);
      case studentCourseLessons:
        return CourseLessonsScreen(courseId: settings.arguments as String? ?? '');
      case studentVideoPlayer:
        final a = settings.arguments as Map<String, dynamic>? ?? {};
        return VideoPlayerScreen(
            lessonId: a['lessonId'] ?? '',
            videoUrl: a['videoUrl'] ?? '',
            title: a['title'] ?? '',
            courseId: a['courseId'] ?? '',
            description: a['description'] ?? '',
            videoSourceType: a['videoSourceType'] ?? 'youtube');
      case studentFilter:
        return const CourseFilterScreen();
      case studentCourseDetails:
        final id = settings.arguments is String
            ? settings.arguments as String
            : ((settings.arguments as Map?)?['id'] ??
                      (settings.arguments as Map?)?['courseId'])
                    ?.toString() ??
                '';
        final initialCourse = settings.arguments is Map<String, dynamic>
            ? settings.arguments as Map<String, dynamic>
            : (settings.arguments is Map
                ? Map<String, dynamic>.from(settings.arguments as Map)
                : null);
        return CourseDetailsScreen(courseId: id, initialCourse: initialCourse);
      case studentBookmarks:
        return const MyBookmarksScreen();
      case studentCurriculum:
        return CourseCurriculumScreen(courseId: settings.arguments as String? ?? '');
      case studentCertificate:
        return const CourseCertificateScreen();
      case studentMyCourses:
        return const StudentMyCoursesListScreen();
      case studentReviews:
        return CourseReviewsScreen(courseId: settings.arguments as String? ?? '');
      case studentWriteReview:
        return WriteReviewScreen(courseId: settings.arguments as String? ?? '');
      case studentPaymentMethods:
        final a = settings.arguments as Map<String, dynamic>? ?? {};
        return PaymentMethodsScreen(
            courseId: a['courseId'] ?? '',
            teacherId: a['teacherId'] ?? '',
            courseTitle: a['courseTitle'] ?? '',
            price: (a['price'] as num?)?.toDouble());
      case studentComments:
        return LessonCommentsScreen(lessonId: settings.arguments as String? ?? '');
      case studentExams:
        return const StudentExamsListScreen();
      case studentExamStart:
        return ExamStartScreen(examData: settings.arguments as Map<String, dynamic>?);
      case studentExamTaking:
        final a = settings.arguments as Map<String, dynamic>? ?? {};
        return ExamTakingScreen(
            examId: a['examId'] as String? ?? '',
            examTitle: a['examTitle'] as String? ?? '',
            maxAttempts: (a['maxAttempts'] as num?)?.toInt() ?? 3,
            attemptsUsed: (a['attemptsUsed'] as num?)?.toInt() ?? 0);
      case studentExamResult:
        return const ExamResultScreen();
      case studentExamAttempts:
        final a = settings.arguments as Map<String, dynamic>? ?? {};
        return ExamAttemptsScreen(examId: a['examId'] ?? '', examTitle: a['examTitle'] ?? '');
      case studentGradeHistory:
        return const GradeHistoryScreen();
      default:
        return null;
    }
  }
}
