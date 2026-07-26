import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_model.freezed.dart';
part 'exam_model.g.dart';

@freezed
class ExamModel with _$ExamModel {
  const factory ExamModel({
    required String id,
    required String teacherId,
    String? courseId,
    required String title,
    required int durationMinutes,
    required DateTime startAt,
    required DateTime endAt,
    @Default(0) int maxScore,
    @Default(false) bool isPublished,
    required DateTime createdAt,
  }) = _ExamModel;

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);
}
