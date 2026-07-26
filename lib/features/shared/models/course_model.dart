import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

@freezed
class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    required String teacherId,
    required String title,
    String? description,
    String? coverImageUrl,
    @Default(false) bool isPublished,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}
