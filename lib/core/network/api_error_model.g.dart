// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiErrorModelImpl _$$ApiErrorModelImplFromJson(Map<String, dynamic> json) =>
    _$ApiErrorModelImpl(
      message: json['message'] as String,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 500,
      error: json['error'] as String?,
      detail: json['detail'] as String?,
    );

Map<String, dynamic> _$$ApiErrorModelImplToJson(_$ApiErrorModelImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'statusCode': instance.statusCode,
      'error': instance.error,
      'detail': instance.detail,
    };
