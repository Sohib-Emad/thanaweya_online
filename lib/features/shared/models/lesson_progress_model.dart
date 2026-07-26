import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_progress_model.freezed.dart';
part 'lesson_progress_model.g.dart';

@freezed
class LessonProgressModel with _$LessonProgressModel {
  const factory LessonProgressModel({
    required String id,
    required String studentId,
    required String lessonId,
    @Default(false) bool isCompleted,
    @Default(0) int watchedSeconds,
    required DateTime lastWatchedAt,
  }) = _LessonProgressModel;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressModelFromJson(json);
}
