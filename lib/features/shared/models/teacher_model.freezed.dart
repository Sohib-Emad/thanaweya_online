// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeacherModel _$TeacherModelFromJson(Map<String, dynamic> json) {
  return _TeacherModel.fromJson(json);
}

/// @nodoc
mixin _$TeacherModel {
  String get id => throw _privateConstructorUsedError;
  String get subjectId => throw _privateConstructorUsedError;
  TeacherStage get stage => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  ApprovalStatus get approvalStatus => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get subscriptionPlanId => throw _privateConstructorUsedError;
  DateTime? get subscriptionExpiresAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TeacherModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherModelCopyWith<TeacherModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherModelCopyWith<$Res> {
  factory $TeacherModelCopyWith(
    TeacherModel value,
    $Res Function(TeacherModel) then,
  ) = _$TeacherModelCopyWithImpl<$Res, TeacherModel>;
  @useResult
  $Res call({
    String id,
    String subjectId,
    TeacherStage stage,
    String? bio,
    ApprovalStatus approvalStatus,
    String? rejectionReason,
    String? subscriptionPlanId,
    DateTime? subscriptionExpiresAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$TeacherModelCopyWithImpl<$Res, $Val extends TeacherModel>
    implements $TeacherModelCopyWith<$Res> {
  _$TeacherModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectId = null,
    Object? stage = null,
    Object? bio = freezed,
    Object? approvalStatus = null,
    Object? rejectionReason = freezed,
    Object? subscriptionPlanId = freezed,
    Object? subscriptionExpiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectId: null == subjectId
                ? _value.subjectId
                : subjectId // ignore: cast_nullable_to_non_nullable
                      as String,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as TeacherStage,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            approvalStatus: null == approvalStatus
                ? _value.approvalStatus
                : approvalStatus // ignore: cast_nullable_to_non_nullable
                      as ApprovalStatus,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            subscriptionPlanId: freezed == subscriptionPlanId
                ? _value.subscriptionPlanId
                : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            subscriptionExpiresAt: freezed == subscriptionExpiresAt
                ? _value.subscriptionExpiresAt
                : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TeacherModelImplCopyWith<$Res>
    implements $TeacherModelCopyWith<$Res> {
  factory _$$TeacherModelImplCopyWith(
    _$TeacherModelImpl value,
    $Res Function(_$TeacherModelImpl) then,
  ) = __$$TeacherModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String subjectId,
    TeacherStage stage,
    String? bio,
    ApprovalStatus approvalStatus,
    String? rejectionReason,
    String? subscriptionPlanId,
    DateTime? subscriptionExpiresAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$TeacherModelImplCopyWithImpl<$Res>
    extends _$TeacherModelCopyWithImpl<$Res, _$TeacherModelImpl>
    implements _$$TeacherModelImplCopyWith<$Res> {
  __$$TeacherModelImplCopyWithImpl(
    _$TeacherModelImpl _value,
    $Res Function(_$TeacherModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subjectId = null,
    Object? stage = null,
    Object? bio = freezed,
    Object? approvalStatus = null,
    Object? rejectionReason = freezed,
    Object? subscriptionPlanId = freezed,
    Object? subscriptionExpiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$TeacherModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectId: null == subjectId
            ? _value.subjectId
            : subjectId // ignore: cast_nullable_to_non_nullable
                  as String,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as TeacherStage,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        approvalStatus: null == approvalStatus
            ? _value.approvalStatus
            : approvalStatus // ignore: cast_nullable_to_non_nullable
                  as ApprovalStatus,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        subscriptionPlanId: freezed == subscriptionPlanId
            ? _value.subscriptionPlanId
            : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        subscriptionExpiresAt: freezed == subscriptionExpiresAt
            ? _value.subscriptionExpiresAt
            : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
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
class _$TeacherModelImpl implements _TeacherModel {
  const _$TeacherModelImpl({
    required this.id,
    required this.subjectId,
    required this.stage,
    this.bio,
    required this.approvalStatus,
    this.rejectionReason,
    this.subscriptionPlanId,
    this.subscriptionExpiresAt,
    required this.createdAt,
  });

  factory _$TeacherModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherModelImplFromJson(json);

  @override
  final String id;
  @override
  final String subjectId;
  @override
  final TeacherStage stage;
  @override
  final String? bio;
  @override
  final ApprovalStatus approvalStatus;
  @override
  final String? rejectionReason;
  @override
  final String? subscriptionPlanId;
  @override
  final DateTime? subscriptionExpiresAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TeacherModel(id: $id, subjectId: $subjectId, stage: $stage, bio: $bio, approvalStatus: $approvalStatus, rejectionReason: $rejectionReason, subscriptionPlanId: $subscriptionPlanId, subscriptionExpiresAt: $subscriptionExpiresAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.subscriptionPlanId, subscriptionPlanId) ||
                other.subscriptionPlanId == subscriptionPlanId) &&
            (identical(other.subscriptionExpiresAt, subscriptionExpiresAt) ||
                other.subscriptionExpiresAt == subscriptionExpiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    subjectId,
    stage,
    bio,
    approvalStatus,
    rejectionReason,
    subscriptionPlanId,
    subscriptionExpiresAt,
    createdAt,
  );

  /// Create a copy of TeacherModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherModelImplCopyWith<_$TeacherModelImpl> get copyWith =>
      __$$TeacherModelImplCopyWithImpl<_$TeacherModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherModelImplToJson(this);
  }
}

abstract class _TeacherModel implements TeacherModel {
  const factory _TeacherModel({
    required final String id,
    required final String subjectId,
    required final TeacherStage stage,
    final String? bio,
    required final ApprovalStatus approvalStatus,
    final String? rejectionReason,
    final String? subscriptionPlanId,
    final DateTime? subscriptionExpiresAt,
    required final DateTime createdAt,
  }) = _$TeacherModelImpl;

  factory _TeacherModel.fromJson(Map<String, dynamic> json) =
      _$TeacherModelImpl.fromJson;

  @override
  String get id;
  @override
  String get subjectId;
  @override
  TeacherStage get stage;
  @override
  String? get bio;
  @override
  ApprovalStatus get approvalStatus;
  @override
  String? get rejectionReason;
  @override
  String? get subscriptionPlanId;
  @override
  DateTime? get subscriptionExpiresAt;
  @override
  DateTime get createdAt;

  /// Create a copy of TeacherModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherModelImplCopyWith<_$TeacherModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
