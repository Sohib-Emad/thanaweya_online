import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_model.freezed.dart';
part 'exam_model.g.dart';

@freezed
class ExamModel with _$ExamModel {
  const factory ExamModel({
    required String id,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    required String title,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'start_at') required DateTime startAt,
    @JsonKey(name: 'end_at') required DateTime endAt,
    @JsonKey(name: 'max_score') @Default(0) int maxScore,
    @JsonKey(name: 'passing_score') @Default(50) int passingScore,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @JsonKey(name: 'allow_retake') @Default(false) bool allowRetake,
    @JsonKey(name: 'max_attempts') @Default(1) int maxAttempts,
    @JsonKey(name: 'shuffle_questions') @Default(false) bool shuffleQuestions,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ExamModel;

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);
}
