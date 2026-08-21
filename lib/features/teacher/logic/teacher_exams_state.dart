import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';

enum TeacherExamsStatus { initial, loading, loaded, error }

class TeacherExamsState {
  final TeacherExamsStatus status;
  final List<ExamModel> exams;
  final List<QuestionModel> questions;
  final TeacherExamsStatus questionsStatus;
  final Map<String, Map<String, int>> questionStats;
  final Map<String, Map<String, int>> examQuestionStats;
  final String? errorMessage;

  const TeacherExamsState({
    this.status = TeacherExamsStatus.initial,
    this.exams = const [],
    this.questions = const [],
    this.questionsStatus = TeacherExamsStatus.initial,
    this.questionStats = const {},
    this.examQuestionStats = const {},
    this.errorMessage,
  });

  TeacherExamsState copyWith({
    TeacherExamsStatus? status,
    List<ExamModel>? exams,
    List<QuestionModel>? questions,
    TeacherExamsStatus? questionsStatus,
    Map<String, Map<String, int>>? questionStats,
    Map<String, Map<String, int>>? examQuestionStats,
    String? errorMessage,
  }) {
    return TeacherExamsState(
      status: status ?? this.status,
      exams: exams ?? this.exams,
      questions: questions ?? this.questions,
      questionsStatus: questionsStatus ?? this.questionsStatus,
      questionStats: questionStats ?? this.questionStats,
      examQuestionStats: examQuestionStats ?? this.examQuestionStats,
      errorMessage: errorMessage,
    );
  }
}
