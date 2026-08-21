// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      questionType: $enumDecode(_$QuestionTypeEnumMap, json['question_type']),
      text: json['text'] as String,
      imageUrl: json['image_url'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctAnswer: json['correct_answer'] as String?,
      points: (json['points'] as num).toInt(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exam_id': instance.examId,
      'question_type': _$QuestionTypeEnumMap[instance.questionType]!,
      'text': instance.text,
      'image_url': instance.imageUrl,
      'options': instance.options,
      'correct_answer': instance.correctAnswer,
      'points': instance.points,
      'order': instance.order,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.mcq: 'mcq',
  QuestionType.trueFalse: 'true_false',
  QuestionType.essay: 'essay',
};
