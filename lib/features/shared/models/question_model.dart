import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

enum QuestionType { mcq, trueFalse, essay }

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required String examId,
    required QuestionType questionType,
    required String text,
    @Default([]) List<String> options,
    String? correctAnswer,
    @Default(1) int points,
    @Default(0) int order,
    required DateTime createdAt,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}
