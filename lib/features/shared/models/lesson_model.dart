import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

enum VideoSourceType { youtube, upload }

@freezed
class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    required String courseId,
    required String title,
    String? description,
    required VideoSourceType videoSourceType,
    required String videoUrlOrId,
    int? durationSeconds,
    String? thumbnailUrl,
    @Default(false) bool isFreePreview,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}
