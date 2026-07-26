// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentModelImpl _$$StudentModelImplFromJson(Map<String, dynamic> json) =>
    _$StudentModelImpl(
      id: json['id'] as String,
      gradeLevel: $enumDecode(_$StudentGradeLevelEnumMap, json['gradeLevel']),
      parentPhone: json['parentPhone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StudentModelImplToJson(_$StudentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gradeLevel': _$StudentGradeLevelEnumMap[instance.gradeLevel]!,
      'parentPhone': instance.parentPhone,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$StudentGradeLevelEnumMap = {
  StudentGradeLevel.first: 'first',
  StudentGradeLevel.second: 'second',
  StudentGradeLevel.third: 'third',
};
