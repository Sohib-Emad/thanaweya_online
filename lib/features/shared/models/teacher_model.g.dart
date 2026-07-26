// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherModelImpl _$$TeacherModelImplFromJson(Map<String, dynamic> json) =>
    _$TeacherModelImpl(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      stage: $enumDecode(_$TeacherStageEnumMap, json['stage']),
      bio: json['bio'] as String?,
      approvalStatus: $enumDecode(
        _$ApprovalStatusEnumMap,
        json['approvalStatus'],
      ),
      rejectionReason: json['rejectionReason'] as String?,
      subscriptionPlanId: json['subscriptionPlanId'] as String?,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
          ? null
          : DateTime.parse(json['subscriptionExpiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TeacherModelImplToJson(
  _$TeacherModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'subjectId': instance.subjectId,
  'stage': _$TeacherStageEnumMap[instance.stage]!,
  'bio': instance.bio,
  'approvalStatus': _$ApprovalStatusEnumMap[instance.approvalStatus]!,
  'rejectionReason': instance.rejectionReason,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'subscriptionExpiresAt': instance.subscriptionExpiresAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
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
