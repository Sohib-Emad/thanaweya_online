// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentModelImpl _$$StudentModelImplFromJson(Map<String, dynamic> json) =>
    _$StudentModelImpl(
      id: json['id'] as String,
      gradeLevel: $enumDecode(_$StudentGradeLevelEnumMap, json['grade_level']),
      parentPhone: json['parent_phone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$StudentModelImplToJson(_$StudentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'grade_level': _$StudentGradeLevelEnumMap[instance.gradeLevel]!,
      'parent_phone': instance.parentPhone,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$StudentGradeLevelEnumMap = {
  StudentGradeLevel.first: 'first',
  StudentGradeLevel.second: 'second',
  StudentGradeLevel.third: 'third',
};
