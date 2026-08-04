// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseModelImpl _$$CourseModelImplFromJson(Map<String, dynamic> json) =>
    _$CourseModelImpl(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CourseModelImplToJson(_$CourseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacher_id': instance.teacherId,
      'title': instance.title,
      'description': instance.description,
      'cover_image_url': instance.coverImageUrl,
      'is_published': instance.isPublished,
      'order': instance.order,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
