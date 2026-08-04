import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

enum VideoSourceType { youtube, upload }

@freezed
class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    @JsonKey(name: 'course_id') required String courseId,
    required String title,
    String? description,
    @JsonKey(name: 'video_source_type') required VideoSourceType videoSourceType,
    @JsonKey(name: 'video_url_or_id') required String videoUrlOrId,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_free_preview') @Default(false) bool isFreePreview,
    @Default(0) int order,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}
