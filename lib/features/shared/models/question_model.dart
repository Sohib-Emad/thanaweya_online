import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

enum QuestionType {
  mcq,
  @JsonValue('true_false')
  trueFalse,
  essay,
}

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    @JsonKey(name: 'exam_id') required String examId,
    @JsonKey(name: 'question_type') required QuestionType questionType,
    required String text,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default([]) List<String> options,
    @JsonKey(name: 'correct_answer') String? correctAnswer,
    required int points,
    @Default(0) int order,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}
