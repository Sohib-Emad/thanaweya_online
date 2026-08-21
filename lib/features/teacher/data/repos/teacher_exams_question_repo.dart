import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/supabase/storage/storage_utils.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';

/// Question CRUD operations extracted from [TeacherExamsRepo].
class TeacherExamsQuestionRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Uploads a question image to the `teacher-documents` bucket.
  Future<String?> uploadQuestionImage({
    required String teacherId,
    required String examId,
    required File imageFile,
  }) async {
    try {
      final ext = imageFile.path.contains('.')
          ? imageFile.path.split('.').last.toLowerCase()
          : 'jpg';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$teacherId/exams/$examId/questions/$fileName';
      final fileBytes = await imageFile.readAsBytes();

      await _client.storage.from('teacher-documents').uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: StorageUtils.resolveMimeType(ext),
            ),
          );

      final url = _client.storage.from('teacher-documents').getPublicUrl(path);
      debugPrint('[TeacherExamsQuestionRepo] Question image uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('[TeacherExamsQuestionRepo] uploadQuestionImage error: $e');
      return null;
    }
  }

  /// Returns question count and total points per exam for a teacher.
  Future<ApiResult<Map<String, Map<String, int>>>> getExamQuestionStats(
    String teacherId,
  ) async {
    try {
      dynamic data;
      try {
        data = await _client
            .from('questions')
            .select('exam_id, points, exams!inner(teacher_id)')
            .eq('exams.teacher_id', teacherId);
      } catch (e) {
        debugPrint(
          '[TeacherExamsQuestionRepo] join query error, fallback to direct query: $e',
        );
        data = await _client.from('questions').select('exam_id, points');
      }

      final stats = <String, Map<String, int>>{};
      if (data is List) {
        for (final row in data) {
          final examId = row['exam_id'] as String?;
          if (examId == null) continue;
          final entry = stats[examId] ?? {'count': 0, 'points': 0};
          entry['count'] = entry['count']! + 1;
          entry['points'] =
              entry['points']! + ((row['points'] as num?)?.toInt() ?? 0);
          stats[examId] = entry;
        }
      }
      return ApiResult.success(stats);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Lists questions for an exam ordered by "order".
  Future<ApiResult<List<QuestionModel>>> getQuestions(String examId) async {
    try {
      final data = await _client
          .from('questions')
          .select()
          .eq('exam_id', examId)
          .order('order');
      return ApiResult.success(
        data.map((e) => QuestionModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Adds a question to an exam.
  ///
  /// Resiliently tries to insert with 'image_url'. If the column does not exist
  /// in the schema cache (PGRST204), falls back to embedding '[image:URL]' in the text field.
  Future<ApiResult<QuestionModel>> addQuestion({
    required String examId,
    required String questionType,
    required String text,
    required List<String> options,
    String? correctAnswer,
    required int points,
    String? imageUrl,
  }) async {
    final validType = (questionType == 'true_false' || questionType == 'tf')
        ? 'true_false'
        : (questionType == 'essay' ? 'essay' : 'mcq');

    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    // First attempt: try with 'image_url' column if an image is provided
    if (hasImage) {
      try {
        final data = await _client
            .from('questions')
            .insert({
              'exam_id': examId,
              'question_type': validType,
              'text': text,
              'options': options,
              'correct_answer': correctAnswer,
              'points': points,
              'image_url': imageUrl.trim(),
            })
            .select()
            .single();
        return ApiResult.success(QuestionModel.fromJson(data));
      } on PostgrestException catch (e) {
        // PGRST204: column not found in schema cache
        if (e.code == 'PGRST204' || e.message.contains('image_url')) {
          debugPrint(
            '[TeacherExamsQuestionRepo] image_url column not found, falling back to text embedding',
          );
        } else {
          return ApiErrorHandler.handleException(e);
        }
      } catch (_) {
        // Fall through to fallback
      }
    }

    // Fallback attempt: if image provided, embed [image:URL] inside text
    try {
      final finalText = (hasImage && !text.contains(imageUrl.trim()))
          ? '$text\n[image:${imageUrl.trim()}]'
          : text;

      final data = await _client
          .from('questions')
          .insert({
            'exam_id': examId,
            'question_type': validType,
            'text': finalText,
            'options': options,
            'correct_answer': correctAnswer,
            'points': points,
          })
          .select()
          .single();
      return ApiResult.success(QuestionModel.fromJson(data));
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Deletes a question by id.
  Future<ApiResult<void>> deleteQuestion(String questionId) async {
    try {
      await _client.from('questions').delete().eq('id', questionId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
