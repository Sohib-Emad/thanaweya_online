// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  body: json['body'] as String? ?? '',
  category: json['category'] as String? ?? 'system',
  isRead: json['is_read'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'body': instance.body,
  'category': instance.category,
  'is_read': instance.isRead,
  'created_at': instance.createdAt.toIso8601String(),
};
