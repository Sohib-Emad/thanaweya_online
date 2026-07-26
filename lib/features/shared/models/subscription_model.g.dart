// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionModelImpl(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  teacherId: json['teacherId'] as String,
  activationCodeId: json['activationCodeId'] as String?,
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  startsAt: DateTime.parse(json['startsAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$SubscriptionModelImplToJson(
  _$SubscriptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'teacherId': instance.teacherId,
  'activationCodeId': instance.activationCodeId,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'startsAt': instance.startsAt.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.suspended: 'suspended',
  SubscriptionStatus.expired: 'expired',
};
