import 'package:flutter/material.dart';

import 'student_course_routes.dart';
import 'student_profile_routes.dart';

/// Composite router for all student routes.
///
/// Delegates to [StudentCourseRoutes] and [StudentProfileRoutes].
class StudentRoutes {
  StudentRoutes._();

  // ─── Re-exported Route Names ────────────────────────────────────────────
  static const String studentSubjects = StudentCourseRoutes.studentSubjects;
  static const String studentTeachers = StudentCourseRoutes.studentTeachers;
  static const String studentForm = StudentCourseRoutes.studentForm;
  static const String studentHome = StudentCourseRoutes.studentHome;
  static const String studentTeacherPage = StudentCourseRoutes.studentTeacherPage;
  static const String studentCourseLessons = StudentCourseRoutes.studentCourseLessons;
  static const String studentVideoPlayer = StudentCourseRoutes.studentVideoPlayer;
  static const String studentExams = StudentCourseRoutes.studentExams;
  static const String studentExamStart = StudentCourseRoutes.studentExamStart;
  static const String studentExamTaking = StudentCourseRoutes.studentExamTaking;
  static const String studentExamResult = StudentCourseRoutes.studentExamResult;
  static const String studentExamAttempts = StudentCourseRoutes.studentExamAttempts;
  static const String studentGradeHistory = StudentCourseRoutes.studentGradeHistory;
  static const String studentFilter = StudentCourseRoutes.studentFilter;
  static const String studentCourseDetails = StudentCourseRoutes.studentCourseDetails;
  static const String studentBookmarks = StudentCourseRoutes.studentBookmarks;
  static const String studentCurriculum = StudentCourseRoutes.studentCurriculum;
  static const String studentCertificate = StudentCourseRoutes.studentCertificate;
  static const String studentMyCourses = StudentCourseRoutes.studentMyCourses;
  static const String studentReviews = StudentCourseRoutes.studentReviews;
  static const String studentWriteReview = StudentCourseRoutes.studentWriteReview;
  static const String studentPaymentMethods = StudentCourseRoutes.studentPaymentMethods;
  static const String studentComments = StudentCourseRoutes.studentComments;
  static const String studentTransactions = StudentProfileRoutes.studentTransactions;
  static const String studentEReceipt = StudentProfileRoutes.studentEReceipt;
  static const String studentProfile = StudentProfileRoutes.studentProfile;
  static const String studentEditProfile = StudentProfileRoutes.studentEditProfile;
  static const String studentNotificationSettings = StudentProfileRoutes.studentNotificationSettings;
  static const String studentPaymentOptions = StudentProfileRoutes.studentPaymentOptions;
  static const String studentAddCard = StudentProfileRoutes.studentAddCard;
  static const String studentChangePassword = StudentProfileRoutes.studentChangePassword;
  static const String studentLanguage = StudentProfileRoutes.studentLanguage;
  static const String studentTerms = StudentProfileRoutes.studentTerms;

  /// Builds the page widget for any student route.
  static Widget? build(RouteSettings settings) =>
      StudentCourseRoutes.build(settings) ?? StudentProfileRoutes.build(settings);
}
