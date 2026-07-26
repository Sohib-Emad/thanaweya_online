// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_error_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiErrorModel _$ApiErrorModelFromJson(Map<String, dynamic> json) {
  return _ApiErrorModel.fromJson(json);
}

/// @nodoc
mixin _$ApiErrorModel {
  String get message => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get detail => throw _privateConstructorUsedError;

  /// Serializes this ApiErrorModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiErrorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiErrorModelCopyWith<ApiErrorModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiErrorModelCopyWith<$Res> {
  factory $ApiErrorModelCopyWith(
    ApiErrorModel value,
    $Res Function(ApiErrorModel) then,
  ) = _$ApiErrorModelCopyWithImpl<$Res, ApiErrorModel>;
  @useResult
  $Res call({String message, int statusCode, String? error, String? detail});
}

/// @nodoc
class _$ApiErrorModelCopyWithImpl<$Res, $Val extends ApiErrorModel>
    implements $ApiErrorModelCopyWith<$Res> {
  _$ApiErrorModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiErrorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = null,
    Object? error = freezed,
    Object? detail = freezed,
  }) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            statusCode: null == statusCode
                ? _value.statusCode
                : statusCode // ignore: cast_nullable_to_non_nullable
                      as int,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            detail: freezed == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiErrorModelImplCopyWith<$Res>
    implements $ApiErrorModelCopyWith<$Res> {
  factory _$$ApiErrorModelImplCopyWith(
    _$ApiErrorModelImpl value,
    $Res Function(_$ApiErrorModelImpl) then,
  ) = __$$ApiErrorModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int statusCode, String? error, String? detail});
}

/// @nodoc
class __$$ApiErrorModelImplCopyWithImpl<$Res>
    extends _$ApiErrorModelCopyWithImpl<$Res, _$ApiErrorModelImpl>
    implements _$$ApiErrorModelImplCopyWith<$Res> {
  __$$ApiErrorModelImplCopyWithImpl(
    _$ApiErrorModelImpl _value,
    $Res Function(_$ApiErrorModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiErrorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = null,
    Object? error = freezed,
    Object? detail = freezed,
  }) {
    return _then(
      _$ApiErrorModelImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: null == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        detail: freezed == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiErrorModelImpl implements _ApiErrorModel {
  const _$ApiErrorModelImpl({
    required this.message,
    this.statusCode = 500,
    this.error,
    this.detail,
  });

  factory _$ApiErrorModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiErrorModelImplFromJson(json);

  @override
  final String message;
  @override
  @JsonKey()
  final int statusCode;
  @override
  final String? error;
  @override
  final String? detail;

  @override
  String toString() {
    return 'ApiErrorModel(message: $message, statusCode: $statusCode, error: $error, detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiErrorModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, message, statusCode, error, detail);

  /// Create a copy of ApiErrorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiErrorModelImplCopyWith<_$ApiErrorModelImpl> get copyWith =>
      __$$ApiErrorModelImplCopyWithImpl<_$ApiErrorModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiErrorModelImplToJson(this);
  }
}

abstract class _ApiErrorModel implements ApiErrorModel {
  const factory _ApiErrorModel({
    required final String message,
    final int statusCode,
    final String? error,
    final String? detail,
  }) = _$ApiErrorModelImpl;

  factory _ApiErrorModel.fromJson(Map<String, dynamic> json) =
      _$ApiErrorModelImpl.fromJson;

  @override
  String get message;
  @override
  int get statusCode;
  @override
  String? get error;
  @override
  String? get detail;

  /// Create a copy of ApiErrorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiErrorModelImplCopyWith<_$ApiErrorModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
