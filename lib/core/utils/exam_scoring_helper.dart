import 'package:thanaweya_online/features/shared/models/question_model.dart';

/// Helper to accurately evaluate whether a student's answer is correct
/// across all representations (option text, option index, letters, true/false variants).
class ExamScoringHelper {
  const ExamScoringHelper._();

  static String _clean(String? s) {
    if (s == null) return '';
    return s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Remove Tashkeel
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\s\-_()]+'), ' ')
        .trim();
  }

  static int? _parseOptionIndex(String? raw, int optionsLength) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.trim();

    // Direct integer: 0, 1, 2, 3...
    final numVal = int.tryParse(text);
    if (numVal != null) {
      if (numVal >= 0 && numVal < optionsLength) return numVal;
      // If 1-based index (1, 2, 3, 4)
      if (numVal >= 1 && numVal <= optionsLength) return numVal - 1;
    }

    // Letters: A, B, C, D or أ, ب, ج, د
    switch (text.toLowerCase()) {
      case 'a':
      case 'أ':
      case 'ا':
        return 0 < optionsLength ? 0 : null;
      case 'b':
      case 'ب':
        return 1 < optionsLength ? 1 : null;
      case 'c':
      case 'ج':
        return 2 < optionsLength ? 2 : null;
      case 'd':
      case 'د':
        return 3 < optionsLength ? 3 : null;
      case 'e':
      case 'هـ':
      case 'ه':
        return 4 < optionsLength ? 4 : null;
      default:
        return null;
    }
  }

  static bool _isTrueVariant(String cleanText) {
    const trueWords = [
      'صواب', 'صح', 'صحيح', 'صواب صح', 'true', '1', 't', 'نعم', 'yes'
    ];
    for (final w in trueWords) {
      if (cleanText == w || cleanText.startsWith(w)) return true;
    }
    return false;
  }

  static bool _isFalseVariant(String cleanText) {
    const falseWords = [
      'خطا', 'خطأ', 'غلط', 'غير صحيح', 'خطا غير صحيح', 'false', '0', 'f', 'لا', 'no'
    ];
    for (final w in falseWords) {
      if (cleanText == w || cleanText.startsWith(w)) return true;
    }
    return false;
  }

  /// Determines if [studentAnswer] is the correct answer for [question].
  static bool isCorrect(QuestionModel question, String? studentAnswer) {
    if (studentAnswer == null || studentAnswer.trim().isEmpty) return false;
    final correctRaw = question.correctAnswer;
    if (correctRaw == null || correctRaw.trim().isEmpty) return false;

    final studentClean = _clean(studentAnswer);
    final correctClean = _clean(correctRaw);

    // 1. Direct text match
    if (studentClean == correctClean) return true;

    // 2. True / False semantic match
    if (question.questionType == QuestionType.trueFalse ||
        question.options.any((o) => o.contains('صواب') || o.contains('صح'))) {
      if (_isTrueVariant(studentClean) && _isTrueVariant(correctClean)) {
        return true;
      }
      if (_isFalseVariant(studentClean) && _isFalseVariant(correctClean)) {
        return true;
      }
    }

    final options = question.options;
    if (options.isEmpty) return false;

    // 3. If correct answer is stored as an index (e.g. "0", "1", "2")
    final correctIdx = _parseOptionIndex(correctRaw, options.length);
    if (correctIdx != null && correctIdx < options.length) {
      final correctOptionText = _clean(options[correctIdx]);
      if (studentClean == correctOptionText) return true;

      final studentIdx = _parseOptionIndex(studentAnswer, options.length);
      if (studentIdx != null && studentIdx == correctIdx) return true;
    }

    // 4. If student answer is stored as an index and correct answer is option text
    final studentIdx = _parseOptionIndex(studentAnswer, options.length);
    if (studentIdx != null && studentIdx < options.length) {
      final studentOptionText = _clean(options[studentIdx]);
      if (studentOptionText == correctClean) return true;
    }

    // 5. Option index lookup in options list
    final studentInOptionsIdx = options.indexWhere((o) => _clean(o) == studentClean);
    if (studentInOptionsIdx != -1 && correctIdx != null) {
      if (studentInOptionsIdx == correctIdx) return true;
    }

    final correctInOptionsIdx = options.indexWhere((o) => _clean(o) == correctClean);
    if (correctInOptionsIdx != -1 && studentIdx != null) {
      if (correctInOptionsIdx == studentIdx) return true;
    }

    return false;
  }
}
