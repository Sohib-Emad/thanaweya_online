// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activation_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivationCodeModelImpl _$$ActivationCodeModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActivationCodeModelImpl(
  id: json['id'] as String,
  teacherId: json['teacherId'] as String,
  courseId: json['courseId'] as String?,
  code: json['code'] as String,
  isUsed: json['isUsed'] as bool? ?? false,
  usedBy: json['usedBy'] as String?,
  usedAt: json['usedAt'] == null
      ? null
      : DateTime.parse(json['usedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ActivationCodeModelImplToJson(
  _$ActivationCodeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'teacherId': instance.teacherId,
  'courseId': instance.courseId,
  'code': instance.code,
  'isUsed': instance.isUsed,
  'usedBy': instance.usedBy,
  'usedAt': instance.usedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
