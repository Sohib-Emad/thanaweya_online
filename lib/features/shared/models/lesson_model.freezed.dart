// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) {
  return _LessonModel.fromJson(json);
}

/// @nodoc
mixin _$LessonModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_id')
  String get courseId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_source_type')
  VideoSourceType get videoSourceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_url_or_id')
  String get videoUrlOrId => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_seconds')
  int? get durationSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_free_preview')
  bool get isFreePreview => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LessonModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonModelCopyWith<LessonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonModelCopyWith<$Res> {
  factory $LessonModelCopyWith(
    LessonModel value,
    $Res Function(LessonModel) then,
  ) = _$LessonModelCopyWithImpl<$Res, LessonModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'course_id') String courseId,
    String title,
    String? description,
    @JsonKey(name: 'video_source_type') VideoSourceType videoSourceType,
    @JsonKey(name: 'video_url_or_id') String videoUrlOrId,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_free_preview') bool isFreePreview,
    int order,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$LessonModelCopyWithImpl<$Res, $Val extends LessonModel>
    implements $LessonModelCopyWith<$Res> {
  _$LessonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? description = freezed,
    Object? videoSourceType = null,
    Object? videoUrlOrId = null,
    Object? durationSeconds = freezed,
    Object? thumbnailUrl = freezed,
    Object? isFreePreview = null,
    Object? order = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            courseId: null == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            videoSourceType: null == videoSourceType
                ? _value.videoSourceType
                : videoSourceType // ignore: cast_nullable_to_non_nullable
                      as VideoSourceType,
            videoUrlOrId: null == videoUrlOrId
                ? _value.videoUrlOrId
                : videoUrlOrId // ignore: cast_nullable_to_non_nullable
                      as String,
            durationSeconds: freezed == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFreePreview: null == isFreePreview
                ? _value.isFreePreview
                : isFreePreview // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonModelImplCopyWith<$Res>
    implements $LessonModelCopyWith<$Res> {
  factory _$$LessonModelImplCopyWith(
    _$LessonModelImpl value,
    $Res Function(_$LessonModelImpl) then,
  ) = __$$LessonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'course_id') String courseId,
    String title,
    String? description,
    @JsonKey(name: 'video_source_type') VideoSourceType videoSourceType,
    @JsonKey(name: 'video_url_or_id') String videoUrlOrId,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_free_preview') bool isFreePreview,
    int order,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$LessonModelImplCopyWithImpl<$Res>
    extends _$LessonModelCopyWithImpl<$Res, _$LessonModelImpl>
    implements _$$LessonModelImplCopyWith<$Res> {
  __$$LessonModelImplCopyWithImpl(
    _$LessonModelImpl _value,
    $Res Function(_$LessonModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? description = freezed,
    Object? videoSourceType = null,
    Object? videoUrlOrId = null,
    Object? durationSeconds = freezed,
    Object? thumbnailUrl = freezed,
    Object? isFreePreview = null,
    Object? order = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$LessonModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        videoSourceType: null == videoSourceType
            ? _value.videoSourceType
            : videoSourceType // ignore: cast_nullable_to_non_nullable
                  as VideoSourceType,
        videoUrlOrId: null == videoUrlOrId
            ? _value.videoUrlOrId
            : videoUrlOrId // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: freezed == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFreePreview: null == isFreePreview
            ? _value.isFreePreview
            : isFreePreview // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonModelImpl implements _LessonModel {
  const _$LessonModelImpl({
    required this.id,
    @JsonKey(name: 'course_id') required this.courseId,
    required this.title,
    this.description,
    @JsonKey(name: 'video_source_type') required this.videoSourceType,
    @JsonKey(name: 'video_url_or_id') required this.videoUrlOrId,
    @JsonKey(name: 'duration_seconds') this.durationSeconds,
    @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
    @JsonKey(name: 'is_free_preview') this.isFreePreview = false,
    this.order = 0,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$LessonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'course_id')
  final String courseId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'video_source_type')
  final VideoSourceType videoSourceType;
  @override
  @JsonKey(name: 'video_url_or_id')
  final String videoUrlOrId;
  @override
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'is_free_preview')
  final bool isFreePreview;
  @override
  @JsonKey()
  final int order;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'LessonModel(id: $id, courseId: $courseId, title: $title, description: $description, videoSourceType: $videoSourceType, videoUrlOrId: $videoUrlOrId, durationSeconds: $durationSeconds, thumbnailUrl: $thumbnailUrl, isFreePreview: $isFreePreview, order: $order, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.videoSourceType, videoSourceType) ||
                other.videoSourceType == videoSourceType) &&
            (identical(other.videoUrlOrId, videoUrlOrId) ||
                other.videoUrlOrId == videoUrlOrId) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.isFreePreview, isFreePreview) ||
                other.isFreePreview == isFreePreview) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    courseId,
    title,
    description,
    videoSourceType,
    videoUrlOrId,
    durationSeconds,
    thumbnailUrl,
    isFreePreview,
    order,
    createdAt,
    updatedAt,
  );

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      __$$LessonModelImplCopyWithImpl<_$LessonModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonModelImplToJson(this);
  }
}

abstract class _LessonModel implements LessonModel {
  const factory _LessonModel({
    required final String id,
    @JsonKey(name: 'course_id') required final String courseId,
    required final String title,
    final String? description,
    @JsonKey(name: 'video_source_type')
    required final VideoSourceType videoSourceType,
    @JsonKey(name: 'video_url_or_id') required final String videoUrlOrId,
    @JsonKey(name: 'duration_seconds') final int? durationSeconds,
    @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
    @JsonKey(name: 'is_free_preview') final bool isFreePreview,
    final int order,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$LessonModelImpl;

  factory _LessonModel.fromJson(Map<String, dynamic> json) =
      _$LessonModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'course_id')
  String get courseId;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'video_source_type')
  VideoSourceType get videoSourceType;
  @override
  @JsonKey(name: 'video_url_or_id')
  String get videoUrlOrId;
  @override
  @JsonKey(name: 'duration_seconds')
  int? get durationSeconds;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'is_free_preview')
  bool get isFreePreview;
  @override
  int get order;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
