import 'mock/mock_auth_data.dart';
import 'mock/mock_subject_data.dart';
import 'mock/mock_course_data.dart';
import 'mock/mock_exam_data.dart';
import 'mock/mock_student_data.dart';
import 'mock/mock_admin_data.dart';

/// Centralized mock data facade for testing and development.
///
/// Delegates to domain-specific mock data classes organized by entity type.
class MockData {
  MockData._();

  // ─── Auth ───────────────────────────────────────────────────────────────
  static const mockEmail = MockAuthData.mockEmail;
  static const mockPassword = MockAuthData.mockPassword;
  static const mockUserName = MockAuthData.mockUserName;
  static const mockStudentName = MockAuthData.mockStudentName;

  // ─── Subjects & Teachers ────────────────────────────────────────────────
  static final mockSubjects = MockSubjectData.mockSubjects;
  static final mockTeachers = MockSubjectData.mockTeachers;

  // ─── Courses & Lessons ──────────────────────────────────────────────────
  static final mockCourses = MockCourseData.mockCourses;
  static final mockLessons = MockCourseData.mockLessons;

  // ─── Exams, Questions & Submissions ─────────────────────────────────────
  static final mockExams = MockExamData.mockExams;
  static final mockQuestions = MockExamData.mockQuestions;
  static final mockSubmissions = MockExamData.mockSubmissions;
  static final mockComments = MockExamData.mockComments;

  // ─── Students ───────────────────────────────────────────────────────────
  static final mockStudents = MockStudentData.mockStudents;

  // ─── Admin ──────────────────────────────────────────────────────────────
  static final mockAdminStats = MockAdminData.mockAdminStats;
  static final mockPendingTeachers = MockAdminData.mockPendingTeachers;
  static final mockAllTeachers = MockAdminData.mockAllTeachers;
  static final mockRecentTeachers = MockAdminData.mockRecentTeachers;
  static final mockPlans = MockAdminData.mockPlans;
}
