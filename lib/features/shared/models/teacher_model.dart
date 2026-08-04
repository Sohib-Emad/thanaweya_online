import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_model.freezed.dart';
part 'teacher_model.g.dart';

enum TeacherStage { first, second, third }

enum ApprovalStatus { pending, approved, rejected }

@freezed
class TeacherModel with _$TeacherModel {
  const factory TeacherModel({
    required String id,
    @JsonKey(name: 'subject_id') required String subjectId,
    required TeacherStage stage,
    String? bio,
    @JsonKey(name: 'approval_status') required ApprovalStatus approvalStatus,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'subscription_plan_id') String? subscriptionPlanId,
    @JsonKey(name: 'subscription_expires_at') DateTime? subscriptionExpiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TeacherModel;

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);
}
