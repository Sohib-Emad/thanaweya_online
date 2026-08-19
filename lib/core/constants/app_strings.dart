import 'strings/general_strings.dart';
import 'strings/auth_strings.dart';
import 'strings/teacher_strings.dart';
import 'strings/student_strings.dart';
import 'strings/exam_strings.dart';
import 'strings/admin_strings.dart';

/// Backward-compatible facade that exposes all UI strings through a single
/// class. Delegates to domain-specific string classes.
class AppStrings {
  AppStrings._();

  // ─── General ────────────────────────────────────────────────────────────
  static const appName = GeneralStrings.appName;
  static const loading = GeneralStrings.loading;
  static const error = GeneralStrings.error;
  static const retry = GeneralStrings.retry;
  static const cancel = GeneralStrings.cancel;
  static const save = GeneralStrings.save;
  static const delete = GeneralStrings.delete;
  static const edit = GeneralStrings.edit;
  static const add = GeneralStrings.add;
  static const confirm = GeneralStrings.confirm;
  static const back = GeneralStrings.back;
  static const next = GeneralStrings.next;
  static const done = GeneralStrings.done;
  static const search = GeneralStrings.search;
  static const noData = GeneralStrings.noData;
  static const offline = GeneralStrings.offline;
  static const offlineMessage = GeneralStrings.offlineMessage;

  // Stages
  static const firstStage = GeneralStrings.firstStage;
  static const secondStage = GeneralStrings.secondStage;
  static const thirdStage = GeneralStrings.thirdStage;

  // Validation
  static const fieldRequired = GeneralStrings.fieldRequired;
  static const invalidEmail = GeneralStrings.invalidEmail;
  static const invalidPhone = GeneralStrings.invalidPhone;
  static const passwordTooShort = GeneralStrings.passwordTooShort;
  static const passwordMismatch = GeneralStrings.passwordMismatch;
  static const invalidOtp = GeneralStrings.invalidOtp;

  // ─── Auth ───────────────────────────────────────────────────────────────
  static const login = AuthStrings.login;
  static const register = AuthStrings.register;
  static const logout = AuthStrings.logout;
  static const email = AuthStrings.email;
  static const password = AuthStrings.password;
  static const confirmPassword = AuthStrings.confirmPassword;
  static const fullName = AuthStrings.fullName;
  static const phone = AuthStrings.phone;
  static const forgotPassword = AuthStrings.forgotPassword;
  static const resetPassword = AuthStrings.resetPassword;
  static const otpVerification = AuthStrings.otpVerification;
  static const enterOtp = AuthStrings.enterOtp;
  static const verify = AuthStrings.verify;
  static const resendCode = AuthStrings.resendCode;
  static const selectRole = AuthStrings.selectRole;
  static const iAmTeacher = AuthStrings.iAmTeacher;
  static const iAmStudent = AuthStrings.iAmStudent;
  static const teacherDescription = AuthStrings.teacherDescription;
  static const studentDescription = AuthStrings.studentDescription;

  // ─── Teacher ────────────────────────────────────────────────────────────
  static const teacherRegistration = TeacherStrings.teacherRegistration;
  static const selectSubject = TeacherStrings.selectSubject;
  static const selectStage = TeacherStrings.selectStage;
  static const bio = TeacherStrings.bio;
  static const pendingReview = TeacherStrings.pendingReview;
  static const pendingReviewMessage = TeacherStrings.pendingReviewMessage;
  static const rejected = TeacherStrings.rejected;
  static const rejectionReason = TeacherStrings.rejectionReason;
  static const teacherDashboard = TeacherStrings.teacherDashboard;
  static const myCourses = TeacherStrings.myCourses;
  static const myStudents = TeacherStrings.myStudents;
  static const myReports = TeacherStrings.myReports;
  static const settings = TeacherStrings.settings;
  static const totalStudents = TeacherStrings.totalStudents;
  static const totalCourses = TeacherStrings.totalCourses;
  static const totalExams = TeacherStrings.totalExams;
  static const createCourse = TeacherStrings.createCourse;
  static const courseName = TeacherStrings.courseName;
  static const courseDescription = TeacherStrings.courseDescription;
  static const coverImage = TeacherStrings.coverImage;
  static const lessons = TeacherStrings.lessons;
  static const lessonsCount = TeacherStrings.lessonsCount;
  static const addLesson = TeacherStrings.addLesson;
  static const lessonTitle = TeacherStrings.lessonTitle;
  static const lessonDescription = TeacherStrings.lessonDescription;
  static const youtubeLink = TeacherStrings.youtubeLink;
  static const uploadVideo = TeacherStrings.uploadVideo;
  static const freePreview = TeacherStrings.freePreview;
  static const publish = TeacherStrings.publish;
  static const studentsList = TeacherStrings.studentsList;
  static const studentDetails = TeacherStrings.studentDetails;
  static const generateCodes = TeacherStrings.generateCodes;
  static const exportCodes = TeacherStrings.exportCodes;

  // ─── Student ────────────────────────────────────────────────────────────
  static const studentRegistration = StudentStrings.studentRegistration;
  static const selectSubjects = StudentStrings.selectSubjects;
  static const selectTeachers = StudentStrings.selectTeachers;
  static const gradeLevel = StudentStrings.gradeLevel;
  static const parentPhone = StudentStrings.parentPhone;
  static const studentDashboard = StudentStrings.studentDashboard;
  static const home = StudentStrings.home;
  static const examsTab = StudentStrings.examsTab;
  static const gradesTab = StudentStrings.gradesTab;

  // ─── Exams ──────────────────────────────────────────────────────────────
  static const createExam = ExamStrings.createExam;
  static const examTitle = ExamStrings.examTitle;
  static const duration = ExamStrings.duration;
  static const startDate = ExamStrings.startDate;
  static const endDate = ExamStrings.endDate;
  static const addQuestion = ExamStrings.addQuestion;
  static const questionType = ExamStrings.questionType;
  static const multipleChoice = ExamStrings.multipleChoice;
  static const trueFalse = ExamStrings.trueFalse;
  static const essay = ExamStrings.essay;
  static const correctAnswer = ExamStrings.correctAnswer;
  static const points = ExamStrings.points;
  static const startExam = ExamStrings.startExam;
  static const submitExam = ExamStrings.submitExam;
  static const examResult = ExamStrings.examResult;
  static const score = ExamStrings.score;
  static const timeRemaining = ExamStrings.timeRemaining;

  // ─── Admin ──────────────────────────────────────────────────────────────
  static const adminDashboard = AdminStrings.adminDashboard;
  static const pendingRequests = AdminStrings.pendingRequests;
  static const approve = AdminStrings.approve;
  static const reject = AdminStrings.reject;
  static const manageSubjects = AdminStrings.manageSubjects;
  static const subscriptionPlans = AdminStrings.subscriptionPlans;
  static const platformReports = AdminStrings.platformReports;
  static const mathematics = AdminStrings.mathematics;
  static const physics = AdminStrings.physics;
  static const chemistry = AdminStrings.chemistry;
  static const biology = AdminStrings.biology;
  static const arabic = AdminStrings.arabic;
  static const english = AdminStrings.english;
  static const french = AdminStrings.french;
  static const history = AdminStrings.history;
  static const geography = AdminStrings.geography;
  static const philosophy = AdminStrings.philosophy;
  static const psychology = AdminStrings.psychology;
}
