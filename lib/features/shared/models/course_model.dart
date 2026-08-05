import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

double? _priceFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

dynamic _priceToJson(double? value) => value;

@freezed
class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    @JsonKey(name: 'teacher_id') required String teacherId,
    required String title,
    String? description,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(fromJson: _priceFromJson, toJson: _priceToJson) double? price,
    @JsonKey(name: 'intro_video_url') String? introVideoUrl,
    @JsonKey(name: 'intro_video_source_type') String? introVideoSourceType,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @Default(0) int order,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}
