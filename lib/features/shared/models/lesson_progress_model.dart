import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_progress_model.freezed.dart';
part 'lesson_progress_model.g.dart';

@freezed
class LessonProgressModel with _$LessonProgressModel {
  const factory LessonProgressModel({
    required String id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'lesson_id') required String lessonId,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'watched_seconds') @Default(0) int watchedSeconds,
    @JsonKey(name: 'last_watched_at') required DateTime lastWatchedAt,
  }) = _LessonProgressModel;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressModelFromJson(json);
}
