import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

enum SubscriptionStatus { active, suspended, expired }

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required String studentId,
    required String teacherId,
    String? activationCodeId,
    required SubscriptionStatus status,
    required DateTime startsAt,
    DateTime? expiresAt,
    required DateTime createdAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}
