import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

enum StudentGradeLevel { first, second, third }

@freezed
class StudentModel with _$StudentModel {
  const factory StudentModel({
    required String id,
    @JsonKey(name: 'grade_level') required StudentGradeLevel gradeLevel,
    @JsonKey(name: 'parent_phone') required String parentPhone,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _StudentModel;

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);
}
