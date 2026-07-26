import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_model.freezed.dart';
part 'teacher_model.g.dart';

enum TeacherStage { first, second, third }

enum ApprovalStatus { pending, approved, rejected }

@freezed
class TeacherModel with _$TeacherModel {
  const factory TeacherModel({
    required String id,
    required String subjectId,
    required TeacherStage stage,
    String? bio,
    required ApprovalStatus approvalStatus,
    String? rejectionReason,
    String? subscriptionPlanId,
    DateTime? subscriptionExpiresAt,
    required DateTime createdAt,
  }) = _TeacherModel;

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);
}
