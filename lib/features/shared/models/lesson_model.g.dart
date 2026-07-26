// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoSourceType: $enumDecode(
        _$VideoSourceTypeEnumMap,
        json['videoSourceType'],
      ),
      videoUrlOrId: json['videoUrlOrId'] as String,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFreePreview: json['isFreePreview'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'description': instance.description,
      'videoSourceType': _$VideoSourceTypeEnumMap[instance.videoSourceType]!,
      'videoUrlOrId': instance.videoUrlOrId,
      'durationSeconds': instance.durationSeconds,
      'thumbnailUrl': instance.thumbnailUrl,
      'isFreePreview': instance.isFreePreview,
      'order': instance.order,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$VideoSourceTypeEnumMap = {
  VideoSourceType.youtube: 'youtube',
  VideoSourceType.upload: 'upload',
};
