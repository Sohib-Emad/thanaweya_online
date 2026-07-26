import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

enum StudentGradeLevel { first, second, third }

@freezed
class StudentModel with _$StudentModel {
  const factory StudentModel({
    required String id,
    required StudentGradeLevel gradeLevel,
    required String parentPhone,
    required DateTime createdAt,
  }) = _StudentModel;

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);
}
