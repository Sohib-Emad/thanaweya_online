// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activation_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActivationCodeModel _$ActivationCodeModelFromJson(Map<String, dynamic> json) {
  return _ActivationCodeModel.fromJson(json);
}

/// @nodoc
mixin _$ActivationCodeModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_id')
  String? get courseId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_used')
  bool get isUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_by')
  String? get usedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_at')
  DateTime? get usedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ActivationCodeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivationCodeModelCopyWith<ActivationCodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivationCodeModelCopyWith<$Res> {
  factory $ActivationCodeModelCopyWith(
    ActivationCodeModel value,
    $Res Function(ActivationCodeModel) then,
  ) = _$ActivationCodeModelCopyWithImpl<$Res, ActivationCodeModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'course_id') String? courseId,
    String code,
    @JsonKey(name: 'is_used') bool isUsed,
    @JsonKey(name: 'used_by') String? usedBy,
    @JsonKey(name: 'used_at') DateTime? usedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ActivationCodeModelCopyWithImpl<$Res, $Val extends ActivationCodeModel>
    implements $ActivationCodeModelCopyWith<$Res> {
  _$ActivationCodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? courseId = freezed,
    Object? code = null,
    Object? isUsed = null,
    Object? usedBy = freezed,
    Object? usedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            courseId: freezed == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as String?,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            isUsed: null == isUsed
                ? _value.isUsed
                : isUsed // ignore: cast_nullable_to_non_nullable
                      as bool,
            usedBy: freezed == usedBy
                ? _value.usedBy
                : usedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            usedAt: freezed == usedAt
                ? _value.usedAt
                : usedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivationCodeModelImplCopyWith<$Res>
    implements $ActivationCodeModelCopyWith<$Res> {
  factory _$$ActivationCodeModelImplCopyWith(
    _$ActivationCodeModelImpl value,
    $Res Function(_$ActivationCodeModelImpl) then,
  ) = __$$ActivationCodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'course_id') String? courseId,
    String code,
    @JsonKey(name: 'is_used') bool isUsed,
    @JsonKey(name: 'used_by') String? usedBy,
    @JsonKey(name: 'used_at') DateTime? usedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ActivationCodeModelImplCopyWithImpl<$Res>
    extends _$ActivationCodeModelCopyWithImpl<$Res, _$ActivationCodeModelImpl>
    implements _$$ActivationCodeModelImplCopyWith<$Res> {
  __$$ActivationCodeModelImplCopyWithImpl(
    _$ActivationCodeModelImpl _value,
    $Res Function(_$ActivationCodeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? courseId = freezed,
    Object? code = null,
    Object? isUsed = null,
    Object? usedBy = freezed,
    Object? usedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ActivationCodeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        courseId: freezed == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        isUsed: null == isUsed
            ? _value.isUsed
            : isUsed // ignore: cast_nullable_to_non_nullable
                  as bool,
        usedBy: freezed == usedBy
            ? _value.usedBy
            : usedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        usedAt: freezed == usedAt
            ? _value.usedAt
            : usedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivationCodeModelImpl implements _ActivationCodeModel {
  const _$ActivationCodeModelImpl({
    required this.id,
    @JsonKey(name: 'teacher_id') required this.teacherId,
    @JsonKey(name: 'course_id') this.courseId,
    required this.code,
    @JsonKey(name: 'is_used') this.isUsed = false,
    @JsonKey(name: 'used_by') this.usedBy,
    @JsonKey(name: 'used_at') this.usedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$ActivationCodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivationCodeModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  @JsonKey(name: 'course_id')
  final String? courseId;
  @override
  final String code;
  @override
  @JsonKey(name: 'is_used')
  final bool isUsed;
  @override
  @JsonKey(name: 'used_by')
  final String? usedBy;
  @override
  @JsonKey(name: 'used_at')
  final DateTime? usedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ActivationCodeModel(id: $id, teacherId: $teacherId, courseId: $courseId, code: $code, isUsed: $isUsed, usedBy: $usedBy, usedAt: $usedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivationCodeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.usedBy, usedBy) || other.usedBy == usedBy) &&
            (identical(other.usedAt, usedAt) || other.usedAt == usedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    teacherId,
    courseId,
    code,
    isUsed,
    usedBy,
    usedAt,
    createdAt,
  );

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivationCodeModelImplCopyWith<_$ActivationCodeModelImpl> get copyWith =>
      __$$ActivationCodeModelImplCopyWithImpl<_$ActivationCodeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivationCodeModelImplToJson(this);
  }
}

abstract class _ActivationCodeModel implements ActivationCodeModel {
  const factory _ActivationCodeModel({
    required final String id,
    @JsonKey(name: 'teacher_id') required final String teacherId,
    @JsonKey(name: 'course_id') final String? courseId,
    required final String code,
    @JsonKey(name: 'is_used') final bool isUsed,
    @JsonKey(name: 'used_by') final String? usedBy,
    @JsonKey(name: 'used_at') final DateTime? usedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ActivationCodeModelImpl;

  factory _ActivationCodeModel.fromJson(Map<String, dynamic> json) =
      _$ActivationCodeModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  @JsonKey(name: 'course_id')
  String? get courseId;
  @override
  String get code;
  @override
  @JsonKey(name: 'is_used')
  bool get isUsed;
  @override
  @JsonKey(name: 'used_by')
  String? get usedBy;
  @override
  @JsonKey(name: 'used_at')
  DateTime? get usedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivationCodeModelImplCopyWith<_$ActivationCodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
