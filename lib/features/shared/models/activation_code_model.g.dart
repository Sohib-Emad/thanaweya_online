// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activation_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivationCodeModelImpl _$$ActivationCodeModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActivationCodeModelImpl(
  id: json['id'] as String,
  teacherId: json['teacher_id'] as String,
  courseId: json['course_id'] as String?,
  code: json['code'] as String,
  isUsed: json['is_used'] as bool? ?? false,
  usedBy: json['used_by'] as String?,
  usedAt: json['used_at'] == null
      ? null
      : DateTime.parse(json['used_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ActivationCodeModelImplToJson(
  _$ActivationCodeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'teacher_id': instance.teacherId,
  'course_id': instance.courseId,
  'code': instance.code,
  'is_used': instance.isUsed,
  'used_by': instance.usedBy,
  'used_at': instance.usedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
