// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      id: json['id'] as String,
      examId: json['examId'] as String,
      questionType: $enumDecode(_$QuestionTypeEnumMap, json['questionType']),
      text: json['text'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctAnswer: json['correctAnswer'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 1,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examId': instance.examId,
      'questionType': _$QuestionTypeEnumMap[instance.questionType]!,
      'text': instance.text,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'points': instance.points,
      'order': instance.order,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.mcq: 'mcq',
  QuestionType.trueFalse: 'trueFalse',
  QuestionType.essay: 'essay',
};
