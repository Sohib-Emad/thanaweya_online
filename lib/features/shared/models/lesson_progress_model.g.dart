// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonProgressModelImpl _$$LessonProgressModelImplFromJson(
  Map<String, dynamic> json,
) => _$LessonProgressModelImpl(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  lessonId: json['lessonId'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  watchedSeconds: (json['watchedSeconds'] as num?)?.toInt() ?? 0,
  lastWatchedAt: DateTime.parse(json['lastWatchedAt'] as String),
);

Map<String, dynamic> _$$LessonProgressModelImplToJson(
  _$LessonProgressModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'lessonId': instance.lessonId,
  'isCompleted': instance.isCompleted,
  'watchedSeconds': instance.watchedSeconds,
  'lastWatchedAt': instance.lastWatchedAt.toIso8601String(),
};
