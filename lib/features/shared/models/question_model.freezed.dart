// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) {
  return _QuestionModel.fromJson(json);
}

/// @nodoc
mixin _$QuestionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'exam_id')
  String get examId => throw _privateConstructorUsedError;
  @JsonKey(name: 'question_type')
  QuestionType get questionType => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  @JsonKey(name: 'correct_answer')
  String? get correctAnswer => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this QuestionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionModelCopyWith<QuestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionModelCopyWith<$Res> {
  factory $QuestionModelCopyWith(
    QuestionModel value,
    $Res Function(QuestionModel) then,
  ) = _$QuestionModelCopyWithImpl<$Res, QuestionModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'exam_id') String examId,
    @JsonKey(name: 'question_type') QuestionType questionType,
    String text,
    List<String> options,
    @JsonKey(name: 'correct_answer') String? correctAnswer,
    int points,
    int order,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$QuestionModelCopyWithImpl<$Res, $Val extends QuestionModel>
    implements $QuestionModelCopyWith<$Res> {
  _$QuestionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? questionType = null,
    Object? text = null,
    Object? options = null,
    Object? correctAnswer = freezed,
    Object? points = null,
    Object? order = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            examId: null == examId
                ? _value.examId
                : examId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionType: null == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as QuestionType,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctAnswer: freezed == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String?,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$QuestionModelImplCopyWith<$Res>
    implements $QuestionModelCopyWith<$Res> {
  factory _$$QuestionModelImplCopyWith(
    _$QuestionModelImpl value,
    $Res Function(_$QuestionModelImpl) then,
  ) = __$$QuestionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'exam_id') String examId,
    @JsonKey(name: 'question_type') QuestionType questionType,
    String text,
    List<String> options,
    @JsonKey(name: 'correct_answer') String? correctAnswer,
    int points,
    int order,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$QuestionModelImplCopyWithImpl<$Res>
    extends _$QuestionModelCopyWithImpl<$Res, _$QuestionModelImpl>
    implements _$$QuestionModelImplCopyWith<$Res> {
  __$$QuestionModelImplCopyWithImpl(
    _$QuestionModelImpl _value,
    $Res Function(_$QuestionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? questionType = null,
    Object? text = null,
    Object? options = null,
    Object? correctAnswer = freezed,
    Object? points = null,
    Object? order = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$QuestionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        examId: null == examId
            ? _value.examId
            : examId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionType: null == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as QuestionType,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctAnswer: freezed == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String?,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$QuestionModelImpl implements _QuestionModel {
  const _$QuestionModelImpl({
    required this.id,
    @JsonKey(name: 'exam_id') required this.examId,
    @JsonKey(name: 'question_type') required this.questionType,
    required this.text,
    final List<String> options = const [],
    @JsonKey(name: 'correct_answer') this.correctAnswer,
    required this.points,
    this.order = 0,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : _options = options;

  factory _$QuestionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'exam_id')
  final String examId;
  @override
  @JsonKey(name: 'question_type')
  final QuestionType questionType;
  @override
  final String text;
  final List<String> _options;
  @override
  @JsonKey()
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  @JsonKey(name: 'correct_answer')
  final String? correctAnswer;
  @override
  final int points;
  @override
  @JsonKey()
  final int order;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'QuestionModel(id: $id, examId: $examId, questionType: $questionType, text: $text, options: $options, correctAnswer: $correctAnswer, points: $points, order: $order, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examId, examId) || other.examId == examId) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examId,
    questionType,
    text,
    const DeepCollectionEquality().hash(_options),
    correctAnswer,
    points,
    order,
    createdAt,
  );

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      __$$QuestionModelImplCopyWithImpl<_$QuestionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionModelImplToJson(this);
  }
}

abstract class _QuestionModel implements QuestionModel {
  const factory _QuestionModel({
    required final String id,
    @JsonKey(name: 'exam_id') required final String examId,
    @JsonKey(name: 'question_type') required final QuestionType questionType,
    required final String text,
    final List<String> options,
    @JsonKey(name: 'correct_answer') final String? correctAnswer,
    required final int points,
    final int order,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$QuestionModelImpl;

  factory _QuestionModel.fromJson(Map<String, dynamic> json) =
      _$QuestionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'exam_id')
  String get examId;
  @override
  @JsonKey(name: 'question_type')
  QuestionType get questionType;
  @override
  String get text;
  @override
  List<String> get options;
  @override
  @JsonKey(name: 'correct_answer')
  String? get correctAnswer;
  @override
  int get points;
  @override
  int get order;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
