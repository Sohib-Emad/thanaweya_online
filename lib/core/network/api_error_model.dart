import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error_model.freezed.dart';
part 'api_error_model.g.dart';

@freezed
class ApiErrorModel with _$ApiErrorModel {
  const factory ApiErrorModel({
    required String message,
    @Default(500) int statusCode,
    String? error,
    String? detail,
  }) = _ApiErrorModel;

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorModelFromJson(json);
}
