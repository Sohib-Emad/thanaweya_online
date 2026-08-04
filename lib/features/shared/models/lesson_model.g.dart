// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoSourceType: $enumDecode(
        _$VideoSourceTypeEnumMap,
        json['video_source_type'],
      ),
      videoUrlOrId: json['video_url_or_id'] as String,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'title': instance.title,
      'description': instance.description,
      'video_source_type': _$VideoSourceTypeEnumMap[instance.videoSourceType]!,
      'video_url_or_id': instance.videoUrlOrId,
      'duration_seconds': instance.durationSeconds,
      'thumbnail_url': instance.thumbnailUrl,
      'is_free_preview': instance.isFreePreview,
      'order': instance.order,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$VideoSourceTypeEnumMap = {
  VideoSourceType.youtube: 'youtube',
  VideoSourceType.upload: 'upload',
};
