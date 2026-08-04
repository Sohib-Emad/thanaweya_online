// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LessonProgressModel _$LessonProgressModelFromJson(Map<String, dynamic> json) {
  return _LessonProgressModel.fromJson(json);
}

/// @nodoc
mixin _$LessonProgressModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_id')
  String get lessonId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'watched_seconds')
  int get watchedSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_watched_at')
  DateTime get lastWatchedAt => throw _privateConstructorUsedError;

  /// Serializes this LessonProgressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonProgressModelCopyWith<LessonProgressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonProgressModelCopyWith<$Res> {
  factory $LessonProgressModelCopyWith(
    LessonProgressModel value,
    $Res Function(LessonProgressModel) then,
  ) = _$LessonProgressModelCopyWithImpl<$Res, LessonProgressModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'lesson_id') String lessonId,
    @JsonKey(name: 'is_completed') bool isCompleted,
    @JsonKey(name: 'watched_seconds') int watchedSeconds,
    @JsonKey(name: 'last_watched_at') DateTime lastWatchedAt,
  });
}

/// @nodoc
class _$LessonProgressModelCopyWithImpl<$Res, $Val extends LessonProgressModel>
    implements $LessonProgressModelCopyWith<$Res> {
  _$LessonProgressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? lessonId = null,
    Object? isCompleted = null,
    Object? watchedSeconds = null,
    Object? lastWatchedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonId: null == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as String,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            watchedSeconds: null == watchedSeconds
                ? _value.watchedSeconds
                : watchedSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            lastWatchedAt: null == lastWatchedAt
                ? _value.lastWatchedAt
                : lastWatchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonProgressModelImplCopyWith<$Res>
    implements $LessonProgressModelCopyWith<$Res> {
  factory _$$LessonProgressModelImplCopyWith(
    _$LessonProgressModelImpl value,
    $Res Function(_$LessonProgressModelImpl) then,
  ) = __$$LessonProgressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'lesson_id') String lessonId,
    @JsonKey(name: 'is_completed') bool isCompleted,
    @JsonKey(name: 'watched_seconds') int watchedSeconds,
    @JsonKey(name: 'last_watched_at') DateTime lastWatchedAt,
  });
}

/// @nodoc
class __$$LessonProgressModelImplCopyWithImpl<$Res>
    extends _$LessonProgressModelCopyWithImpl<$Res, _$LessonProgressModelImpl>
    implements _$$LessonProgressModelImplCopyWith<$Res> {
  __$$LessonProgressModelImplCopyWithImpl(
    _$LessonProgressModelImpl _value,
    $Res Function(_$LessonProgressModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? lessonId = null,
    Object? isCompleted = null,
    Object? watchedSeconds = null,
    Object? lastWatchedAt = null,
  }) {
    return _then(
      _$LessonProgressModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonId: null == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as String,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        watchedSeconds: null == watchedSeconds
            ? _value.watchedSeconds
            : watchedSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        lastWatchedAt: null == lastWatchedAt
            ? _value.lastWatchedAt
            : lastWatchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonProgressModelImpl implements _LessonProgressModel {
  const _$LessonProgressModelImpl({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'lesson_id') required this.lessonId,
    @JsonKey(name: 'is_completed') this.isCompleted = false,
    @JsonKey(name: 'watched_seconds') this.watchedSeconds = 0,
    @JsonKey(name: 'last_watched_at') required this.lastWatchedAt,
  });

  factory _$LessonProgressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonProgressModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey(name: 'lesson_id')
  final String lessonId;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'watched_seconds')
  final int watchedSeconds;
  @override
  @JsonKey(name: 'last_watched_at')
  final DateTime lastWatchedAt;

  @override
  String toString() {
    return 'LessonProgressModel(id: $id, studentId: $studentId, lessonId: $lessonId, isCompleted: $isCompleted, watchedSeconds: $watchedSeconds, lastWatchedAt: $lastWatchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonProgressModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.watchedSeconds, watchedSeconds) ||
                other.watchedSeconds == watchedSeconds) &&
            (identical(other.lastWatchedAt, lastWatchedAt) ||
                other.lastWatchedAt == lastWatchedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    lessonId,
    isCompleted,
    watchedSeconds,
    lastWatchedAt,
  );

  /// Create a copy of LessonProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonProgressModelImplCopyWith<_$LessonProgressModelImpl> get copyWith =>
      __$$LessonProgressModelImplCopyWithImpl<_$LessonProgressModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonProgressModelImplToJson(this);
  }
}

abstract class _LessonProgressModel implements LessonProgressModel {
  const factory _LessonProgressModel({
    required final String id,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'lesson_id') required final String lessonId,
    @JsonKey(name: 'is_completed') final bool isCompleted,
    @JsonKey(name: 'watched_seconds') final int watchedSeconds,
    @JsonKey(name: 'last_watched_at') required final DateTime lastWatchedAt,
  }) = _$LessonProgressModelImpl;

  factory _LessonProgressModel.fromJson(Map<String, dynamic> json) =
      _$LessonProgressModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  @JsonKey(name: 'lesson_id')
  String get lessonId;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted;
  @override
  @JsonKey(name: 'watched_seconds')
  int get watchedSeconds;
  @override
  @JsonKey(name: 'last_watched_at')
  DateTime get lastWatchedAt;

  /// Create a copy of LessonProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonProgressModelImplCopyWith<_$LessonProgressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
