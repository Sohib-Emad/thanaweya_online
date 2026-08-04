// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherModelImpl _$$TeacherModelImplFromJson(Map<String, dynamic> json) =>
    _$TeacherModelImpl(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      stage: $enumDecode(_$TeacherStageEnumMap, json['stage']),
      bio: json['bio'] as String?,
      approvalStatus: $enumDecode(
        _$ApprovalStatusEnumMap,
        json['approval_status'],
      ),
      rejectionReason: json['rejection_reason'] as String?,
      subscriptionPlanId: json['subscription_plan_id'] as String?,
      subscriptionExpiresAt: json['subscription_expires_at'] == null
          ? null
          : DateTime.parse(json['subscription_expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TeacherModelImplToJson(
  _$TeacherModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'subject_id': instance.subjectId,
  'stage': _$TeacherStageEnumMap[instance.stage]!,
  'bio': instance.bio,
  'approval_status': _$ApprovalStatusEnumMap[instance.approvalStatus]!,
  'rejection_reason': instance.rejectionReason,
  'subscription_plan_id': instance.subscriptionPlanId,
  'subscription_expires_at': instance.subscriptionExpiresAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$TeacherStageEnumMap = {
  TeacherStage.first: 'first',
  TeacherStage.second: 'second',
  TeacherStage.third: 'third',
};

const _$ApprovalStatusEnumMap = {
  ApprovalStatus.pending: 'pending',
  ApprovalStatus.approved: 'approved',
  ApprovalStatus.rejected: 'rejected',
};
