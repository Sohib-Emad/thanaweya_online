// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionModelImpl(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  teacherId: json['teacher_id'] as String,
  activationCodeId: json['activation_code_id'] as String?,
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  startsAt: DateTime.parse(json['starts_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$SubscriptionModelImplToJson(
  _$SubscriptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'teacher_id': instance.teacherId,
  'activation_code_id': instance.activationCodeId,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'starts_at': instance.startsAt.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.suspended: 'suspended',
  SubscriptionStatus.expired: 'expired',
};
