import 'package:freezed_annotation/freezed_annotation.dart';

part 'activation_code_model.freezed.dart';
part 'activation_code_model.g.dart';

@freezed
class ActivationCodeModel with _$ActivationCodeModel {
  const factory ActivationCodeModel({
    required String id,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'course_id') String? courseId,
    required String code,
    @JsonKey(name: 'is_used') @Default(false) bool isUsed,
    @JsonKey(name: 'used_by') String? usedBy,
    @JsonKey(name: 'used_at') DateTime? usedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ActivationCodeModel;

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ActivationCodeModelFromJson(json);
}
