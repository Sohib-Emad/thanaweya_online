// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) {
  return _SubscriptionModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  @JsonKey(name: 'activation_code_id')
  String? get activationCodeId => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'starts_at')
  DateTime get startsAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionModelCopyWith<SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionModelCopyWith<$Res> {
  factory $SubscriptionModelCopyWith(
    SubscriptionModel value,
    $Res Function(SubscriptionModel) then,
  ) = _$SubscriptionModelCopyWithImpl<$Res, SubscriptionModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'activation_code_id') String? activationCodeId,
    SubscriptionStatus status,
    @JsonKey(name: 'starts_at') DateTime startsAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res, $Val extends SubscriptionModel>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? teacherId = null,
    Object? activationCodeId = freezed,
    Object? status = null,
    Object? startsAt = null,
    Object? expiresAt = freezed,
    Object? createdAt = null,
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
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            activationCodeId: freezed == activationCodeId
                ? _value.activationCodeId
                : activationCodeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            startsAt: null == startsAt
                ? _value.startsAt
                : startsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SubscriptionModelImplCopyWith<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  factory _$$SubscriptionModelImplCopyWith(
    _$SubscriptionModelImpl value,
    $Res Function(_$SubscriptionModelImpl) then,
  ) = __$$SubscriptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'activation_code_id') String? activationCodeId,
    SubscriptionStatus status,
    @JsonKey(name: 'starts_at') DateTime startsAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$SubscriptionModelImplCopyWithImpl<$Res>
    extends _$SubscriptionModelCopyWithImpl<$Res, _$SubscriptionModelImpl>
    implements _$$SubscriptionModelImplCopyWith<$Res> {
  __$$SubscriptionModelImplCopyWithImpl(
    _$SubscriptionModelImpl _value,
    $Res Function(_$SubscriptionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? teacherId = null,
    Object? activationCodeId = freezed,
    Object? status = null,
    Object? startsAt = null,
    Object? expiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$SubscriptionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        activationCodeId: freezed == activationCodeId
            ? _value.activationCodeId
            : activationCodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        startsAt: null == startsAt
            ? _value.startsAt
            : startsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
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
class _$SubscriptionModelImpl implements _SubscriptionModel {
  const _$SubscriptionModelImpl({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'teacher_id') required this.teacherId,
    @JsonKey(name: 'activation_code_id') this.activationCodeId,
    required this.status,
    @JsonKey(name: 'starts_at') required this.startsAt,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$SubscriptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  @JsonKey(name: 'activation_code_id')
  final String? activationCodeId;
  @override
  final SubscriptionStatus status;
  @override
  @JsonKey(name: 'starts_at')
  final DateTime startsAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, studentId: $studentId, teacherId: $teacherId, activationCodeId: $activationCodeId, status: $status, startsAt: $startsAt, expiresAt: $expiresAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.activationCodeId, activationCodeId) ||
                other.activationCodeId == activationCodeId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    teacherId,
    activationCodeId,
    status,
    startsAt,
    expiresAt,
    createdAt,
  );

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      __$$SubscriptionModelImplCopyWithImpl<_$SubscriptionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionModelImplToJson(this);
  }
}

abstract class _SubscriptionModel implements SubscriptionModel {
  const factory _SubscriptionModel({
    required final String id,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'teacher_id') required final String teacherId,
    @JsonKey(name: 'activation_code_id') final String? activationCodeId,
    required final SubscriptionStatus status,
    @JsonKey(name: 'starts_at') required final DateTime startsAt,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$SubscriptionModelImpl;

  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) =
      _$SubscriptionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  @JsonKey(name: 'activation_code_id')
  String? get activationCodeId;
  @override
  SubscriptionStatus get status;
  @override
  @JsonKey(name: 'starts_at')
  DateTime get startsAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
