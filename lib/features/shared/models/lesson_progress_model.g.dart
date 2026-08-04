// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonProgressModelImpl _$$LessonProgressModelImplFromJson(
  Map<String, dynamic> json,
) => _$LessonProgressModelImpl(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  lessonId: json['lesson_id'] as String,
  isCompleted: json['is_completed'] as bool? ?? false,
  watchedSeconds: (json['watched_seconds'] as num?)?.toInt() ?? 0,
  lastWatchedAt: DateTime.parse(json['last_watched_at'] as String),
);

Map<String, dynamic> _$$LessonProgressModelImplToJson(
  _$LessonProgressModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'lesson_id': instance.lessonId,
  'is_completed': instance.isCompleted,
  'watched_seconds': instance.watchedSeconds,
  'last_watched_at': instance.lastWatchedAt.toIso8601String(),
};
