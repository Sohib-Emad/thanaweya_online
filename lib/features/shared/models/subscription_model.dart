import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

enum SubscriptionStatus { active, suspended, expired }

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'activation_code_id') String? activationCodeId,
    required SubscriptionStatus status,
    @JsonKey(name: 'starts_at') required DateTime startsAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}
