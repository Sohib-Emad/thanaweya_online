// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamModelImpl _$$ExamModelImplFromJson(Map<String, dynamic> json) =>
    _$ExamModelImpl(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      courseId: json['courseId'] as String?,
      title: json['title'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ExamModelImplToJson(_$ExamModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'courseId': instance.courseId,
      'title': instance.title,
      'durationMinutes': instance.durationMinutes,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt.toIso8601String(),
      'maxScore': instance.maxScore,
      'isPublished': instance.isPublished,
      'createdAt': instance.createdAt.toIso8601String(),
    };
