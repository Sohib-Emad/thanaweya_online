import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';

enum StudentExamsStatus { initial, loading, loaded, error }

class StudentExamsState {
  final StudentExamsStatus status;
  final List<Map<String, dynamic>> availableExams;
  final StudentExamsStatus examStatus;
  final ExamModel? currentExam;
  final List<QuestionModel> currentQuestions;
  final Map<String, String> answers;
  final int currentQuestionIndex;
  final StudentExamsStatus submissionStatus;
  final int? lastScore;
  final int? lastTotalPoints;
  final StudentExamsStatus submissionsStatus;
  final List<Map<String, dynamic>> submissions;
  final StudentExamsStatus attemptsStatus;
  final List<Map<String, dynamic>> attempts;
  final String? errorMessage;

  const StudentExamsState({
    this.status = StudentExamsStatus.initial,
    this.availableExams = const [],
    this.examStatus = StudentExamsStatus.initial,
    this.currentExam,
    this.currentQuestions = const [],
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.submissionStatus = StudentExamsStatus.initial,
    this.lastScore,
    this.lastTotalPoints,
    this.submissionsStatus = StudentExamsStatus.initial,
    this.submissions = const [],
    this.attemptsStatus = StudentExamsStatus.initial,
    this.attempts = const [],
    this.errorMessage,
  });

  StudentExamsState copyWith({
    StudentExamsStatus? status,
    List<Map<String, dynamic>>? availableExams,
    StudentExamsStatus? examStatus,
    ExamModel? currentExam,
    List<QuestionModel>? currentQuestions,
    Map<String, String>? answers,
    int? currentQuestionIndex,
    StudentExamsStatus? submissionStatus,
    int? lastScore,
    int? lastTotalPoints,
    StudentExamsStatus? submissionsStatus,
    List<Map<String, dynamic>>? submissions,
    StudentExamsStatus? attemptsStatus,
    List<Map<String, dynamic>>? attempts,
    String? errorMessage,
  }) {
    return StudentExamsState(
      status: status ?? this.status,
      availableExams: availableExams ?? this.availableExams,
      examStatus: examStatus ?? this.examStatus,
      currentExam: currentExam ?? this.currentExam,
      currentQuestions: currentQuestions ?? this.currentQuestions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      lastScore: lastScore ?? this.lastScore,
      lastTotalPoints: lastTotalPoints ?? this.lastTotalPoints,
      submissionsStatus: submissionsStatus ?? this.submissionsStatus,
      submissions: submissions ?? this.submissions,
      attemptsStatus: attemptsStatus ?? this.attemptsStatus,
      attempts: attempts ?? this.attempts,
      errorMessage: errorMessage,
    );
  }
}
