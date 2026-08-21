// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamModel _$ExamModelFromJson(Map<String, dynamic> json) {
  return _ExamModel.fromJson(json);
}

/// @nodoc
mixin _$ExamModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_id')
  String? get courseId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_id')
  String? get lessonId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_at')
  DateTime get startAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_at')
  DateTime get endAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_score')
  int get maxScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'passing_score')
  int get passingScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_published')
  bool get isPublished => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_retake')
  bool get allowRetake => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_attempts')
  int get maxAttempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'shuffle_questions')
  bool get shuffleQuestions => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ExamModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamModelCopyWith<ExamModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamModelCopyWith<$Res> {
  factory $ExamModelCopyWith(ExamModel value, $Res Function(ExamModel) then) =
      _$ExamModelCopyWithImpl<$Res, ExamModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    String title,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'start_at') DateTime startAt,
    @JsonKey(name: 'end_at') DateTime endAt,
    @JsonKey(name: 'max_score') int maxScore,
    @JsonKey(name: 'passing_score') int passingScore,
    @JsonKey(name: 'is_published') bool isPublished,
    @JsonKey(name: 'allow_retake') bool allowRetake,
    @JsonKey(name: 'max_attempts') int maxAttempts,
    @JsonKey(name: 'shuffle_questions') bool shuffleQuestions,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ExamModelCopyWithImpl<$Res, $Val extends ExamModel>
    implements $ExamModelCopyWith<$Res> {
  _$ExamModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? courseId = freezed,
    Object? lessonId = freezed,
    Object? title = null,
    Object? durationMinutes = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? maxScore = null,
    Object? passingScore = null,
    Object? isPublished = null,
    Object? allowRetake = null,
    Object? maxAttempts = null,
    Object? shuffleQuestions = null,
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
            lessonId: freezed == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            startAt: null == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endAt: null == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            passingScore: null == passingScore
                ? _value.passingScore
                : passingScore // ignore: cast_nullable_to_non_nullable
                      as int,
            isPublished: null == isPublished
                ? _value.isPublished
                : isPublished // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowRetake: null == allowRetake
                ? _value.allowRetake
                : allowRetake // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxAttempts: null == maxAttempts
                ? _value.maxAttempts
                : maxAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            shuffleQuestions: null == shuffleQuestions
                ? _value.shuffleQuestions
                : shuffleQuestions // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$ExamModelImplCopyWith<$Res>
    implements $ExamModelCopyWith<$Res> {
  factory _$$ExamModelImplCopyWith(
    _$ExamModelImpl value,
    $Res Function(_$ExamModelImpl) then,
  ) = __$$ExamModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'teacher_id') String teacherId,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    String title,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'start_at') DateTime startAt,
    @JsonKey(name: 'end_at') DateTime endAt,
    @JsonKey(name: 'max_score') int maxScore,
    @JsonKey(name: 'passing_score') int passingScore,
    @JsonKey(name: 'is_published') bool isPublished,
    @JsonKey(name: 'allow_retake') bool allowRetake,
    @JsonKey(name: 'max_attempts') int maxAttempts,
    @JsonKey(name: 'shuffle_questions') bool shuffleQuestions,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ExamModelImplCopyWithImpl<$Res>
    extends _$ExamModelCopyWithImpl<$Res, _$ExamModelImpl>
    implements _$$ExamModelImplCopyWith<$Res> {
  __$$ExamModelImplCopyWithImpl(
    _$ExamModelImpl _value,
    $Res Function(_$ExamModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? courseId = freezed,
    Object? lessonId = freezed,
    Object? title = null,
    Object? durationMinutes = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? maxScore = null,
    Object? passingScore = null,
    Object? isPublished = null,
    Object? allowRetake = null,
    Object? maxAttempts = null,
    Object? shuffleQuestions = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ExamModelImpl(
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
        lessonId: freezed == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        startAt: null == startAt
            ? _value.startAt
            : startAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endAt: null == endAt
            ? _value.endAt
            : endAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        passingScore: null == passingScore
            ? _value.passingScore
            : passingScore // ignore: cast_nullable_to_non_nullable
                  as int,
        isPublished: null == isPublished
            ? _value.isPublished
            : isPublished // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowRetake: null == allowRetake
            ? _value.allowRetake
            : allowRetake // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxAttempts: null == maxAttempts
            ? _value.maxAttempts
            : maxAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        shuffleQuestions: null == shuffleQuestions
            ? _value.shuffleQuestions
            : shuffleQuestions // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$ExamModelImpl implements _ExamModel {
  const _$ExamModelImpl({
    required this.id,
    @JsonKey(name: 'teacher_id') required this.teacherId,
    @JsonKey(name: 'course_id') this.courseId,
    @JsonKey(name: 'lesson_id') this.lessonId,
    required this.title,
    @JsonKey(name: 'duration_minutes') required this.durationMinutes,
    @JsonKey(name: 'start_at') required this.startAt,
    @JsonKey(name: 'end_at') required this.endAt,
    @JsonKey(name: 'max_score') this.maxScore = 0,
    @JsonKey(name: 'passing_score') this.passingScore = 50,
    @JsonKey(name: 'is_published') this.isPublished = false,
    @JsonKey(name: 'allow_retake') this.allowRetake = false,
    @JsonKey(name: 'max_attempts') this.maxAttempts = 1,
    @JsonKey(name: 'shuffle_questions') this.shuffleQuestions = false,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$ExamModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  @JsonKey(name: 'course_id')
  final String? courseId;
  @override
  @JsonKey(name: 'lesson_id')
  final String? lessonId;
  @override
  final String title;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'start_at')
  final DateTime startAt;
  @override
  @JsonKey(name: 'end_at')
  final DateTime endAt;
  @override
  @JsonKey(name: 'max_score')
  final int maxScore;
  @override
  @JsonKey(name: 'passing_score')
  final int passingScore;
  @override
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @override
  @JsonKey(name: 'allow_retake')
  final bool allowRetake;
  @override
  @JsonKey(name: 'max_attempts')
  final int maxAttempts;
  @override
  @JsonKey(name: 'shuffle_questions')
  final bool shuffleQuestions;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ExamModel(id: $id, teacherId: $teacherId, courseId: $courseId, lessonId: $lessonId, title: $title, durationMinutes: $durationMinutes, startAt: $startAt, endAt: $endAt, maxScore: $maxScore, passingScore: $passingScore, isPublished: $isPublished, allowRetake: $allowRetake, maxAttempts: $maxAttempts, shuffleQuestions: $shuffleQuestions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.passingScore, passingScore) ||
                other.passingScore == passingScore) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.allowRetake, allowRetake) ||
                other.allowRetake == allowRetake) &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.shuffleQuestions, shuffleQuestions) ||
                other.shuffleQuestions == shuffleQuestions) &&
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
    lessonId,
    title,
    durationMinutes,
    startAt,
    endAt,
    maxScore,
    passingScore,
    isPublished,
    allowRetake,
    maxAttempts,
    shuffleQuestions,
    createdAt,
  );

  /// Create a copy of ExamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamModelImplCopyWith<_$ExamModelImpl> get copyWith =>
      __$$ExamModelImplCopyWithImpl<_$ExamModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamModelImplToJson(this);
  }
}

abstract class _ExamModel implements ExamModel {
  const factory _ExamModel({
    required final String id,
    @JsonKey(name: 'teacher_id') required final String teacherId,
    @JsonKey(name: 'course_id') final String? courseId,
    @JsonKey(name: 'lesson_id') final String? lessonId,
    required final String title,
    @JsonKey(name: 'duration_minutes') required final int durationMinutes,
    @JsonKey(name: 'start_at') required final DateTime startAt,
    @JsonKey(name: 'end_at') required final DateTime endAt,
    @JsonKey(name: 'max_score') final int maxScore,
    @JsonKey(name: 'passing_score') final int passingScore,
    @JsonKey(name: 'is_published') final bool isPublished,
    @JsonKey(name: 'allow_retake') final bool allowRetake,
    @JsonKey(name: 'max_attempts') final int maxAttempts,
    @JsonKey(name: 'shuffle_questions') final bool shuffleQuestions,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ExamModelImpl;

  factory _ExamModel.fromJson(Map<String, dynamic> json) =
      _$ExamModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  @JsonKey(name: 'course_id')
  String? get courseId;
  @override
  @JsonKey(name: 'lesson_id')
  String? get lessonId;
  @override
  String get title;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'start_at')
  DateTime get startAt;
  @override
  @JsonKey(name: 'end_at')
  DateTime get endAt;
  @override
  @JsonKey(name: 'max_score')
  int get maxScore;
  @override
  @JsonKey(name: 'passing_score')
  int get passingScore;
  @override
  @JsonKey(name: 'is_published')
  bool get isPublished;
  @override
  @JsonKey(name: 'allow_retake')
  bool get allowRetake;
  @override
  @JsonKey(name: 'max_attempts')
  int get maxAttempts;
  @override
  @JsonKey(name: 'shuffle_questions')
  bool get shuffleQuestions;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ExamModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamModelImplCopyWith<_$ExamModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
