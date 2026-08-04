import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    @JsonKey(name: 'lesson_id') required String lessonId,
    @JsonKey(name: 'author_id') required String authorId,
    required String text,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
