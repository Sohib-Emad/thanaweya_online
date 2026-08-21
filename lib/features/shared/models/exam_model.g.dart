// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamModelImpl _$$ExamModelImplFromJson(Map<String, dynamic> json) =>
    _$ExamModelImpl(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      courseId: json['course_id'] as String?,
      lessonId: json['lesson_id'] as String?,
      title: json['title'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      maxScore: (json['max_score'] as num?)?.toInt() ?? 0,
      passingScore: (json['passing_score'] as num?)?.toInt() ?? 50,
      isPublished: json['is_published'] as bool? ?? false,
      allowRetake: json['allow_retake'] as bool? ?? false,
      maxAttempts: (json['max_attempts'] as num?)?.toInt() ?? 1,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ExamModelImplToJson(_$ExamModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacher_id': instance.teacherId,
      'course_id': instance.courseId,
      'lesson_id': instance.lessonId,
      'title': instance.title,
      'duration_minutes': instance.durationMinutes,
      'start_at': instance.startAt.toIso8601String(),
      'end_at': instance.endAt.toIso8601String(),
      'max_score': instance.maxScore,
      'passing_score': instance.passingScore,
      'is_published': instance.isPublished,
      'allow_retake': instance.allowRetake,
      'max_attempts': instance.maxAttempts,
      'shuffle_questions': instance.shuffleQuestions,
      'created_at': instance.createdAt.toIso8601String(),
    };
