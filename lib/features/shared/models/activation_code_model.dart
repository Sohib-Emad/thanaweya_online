import 'package:freezed_annotation/freezed_annotation.dart';

part 'activation_code_model.freezed.dart';
part 'activation_code_model.g.dart';

@freezed
class ActivationCodeModel with _$ActivationCodeModel {
  const factory ActivationCodeModel({
    required String id,
    required String teacherId,
    String? courseId,
    required String code,
    @Default(false) bool isUsed,
    String? usedBy,
    DateTime? usedAt,
    required DateTime createdAt,
  }) = _ActivationCodeModel;

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ActivationCodeModelFromJson(json);
}
