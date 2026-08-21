import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';

/// Represents the evaluated lock and prerequisite status for a single lesson.
class LessonLockStatus {
  final bool isUnlocked;
  final bool isCompleted;
  final bool isExamRequired;
  final bool isExamPassed;
  final String? lockReason;
  final Map<String, dynamic>? requiredExam;
  final String? previousLessonTitle;
  final LessonModel? previousLesson;

  const LessonLockStatus({
    required this.isUnlocked,
    required this.isCompleted,
    this.isExamRequired = false,
    this.isExamPassed = false,
    this.lockReason,
    this.requiredExam,
    this.previousLessonTitle,
    this.previousLesson,
  });
}

/// Helper that calculates sequential unlocking and exam prerequisites
/// across lessons in a course.
class LessonProgressionHelper {
  const LessonProgressionHelper._();

  /// Evaluates lock status for all lessons in [lessons] sequentially.
  static Map<String, LessonLockStatus> evaluateLessons({
    required List<LessonModel> lessons,
    required List<LessonProgressModel> progress,
    required bool isSubscribed,
    List<Map<String, dynamic>> courseExams = const [],
    List<Map<String, dynamic>> examSubmissions = const [],
  }) {
    final result = <String, LessonLockStatus>{};
    if (lessons.isEmpty) return result;

    final progressMap = <String, LessonProgressModel>{
      for (final p in progress) p.lessonId: p,
    };

    // Map lesson_id -> exam
    final examsByLesson = <String, Map<String, dynamic>>{};
    for (final e in courseExams) {
      final lId = e['lesson_id'] as String? ?? '';
      if (lId.isNotEmpty) {
        examsByLesson[lId] = e;
      }
    }

    // Map exam_id -> best submission
    final submissionsByExam = <String, Map<String, dynamic>>{};
    for (final s in examSubmissions) {
      final eId = s['exam_id'] as String? ?? '';
      if (eId.isNotEmpty) {
        submissionsByExam[eId] = s;
      }
    }

    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final prog = progressMap[lesson.id];
      final duration = lesson.durationSeconds ?? 0;
      final watched = prog?.watchedSeconds ?? 0;
      final isCompleted = prog?.isCompleted == true ||
          (duration > 0 && watched >= (duration * 0.9).round());

      // 1. Subscription check
      if (!isSubscribed && !lesson.isFreePreview) {
        result[lesson.id] = LessonLockStatus(
          isUnlocked: false,
          isCompleted: isCompleted,
          lockReason: 'يتطلب الاشتراك في الدورة',
        );
        continue;
      }

      // 2. First lesson is always unlocked if subscribed / free preview
      if (i == 0) {
        result[lesson.id] = LessonLockStatus(
          isUnlocked: true,
          isCompleted: isCompleted,
        );
        continue;
      }

      // 3. For lesson i > 0, inspect previous lesson (i - 1)
      final prevLesson = lessons[i - 1];
      final prevProg = progressMap[prevLesson.id];
      final prevDuration = prevLesson.durationSeconds ?? 0;
      final prevWatched = prevProg?.watchedSeconds ?? 0;
      final isPrevCompleted = prevProg?.isCompleted == true ||
          (prevDuration > 0 && prevWatched >= (prevDuration * 0.9).round());

      final prevExam = examsByLesson[prevLesson.id];

      if (prevExam != null) {
        // Previous lesson HAS a mandatory exam
        final examId = prevExam['id'] as String? ?? '';
        final passingScore =
            (prevExam['passing_score'] as num?)?.toInt() ?? 50;
        final sub = submissionsByExam[examId];

        bool isPassed = false;
        if (sub != null) {
          final score = (sub['score'] as num?)?.toInt() ?? 0;
          final total = (sub['total_points'] as num?)?.toInt() ?? 100;
          final pct = total > 0 ? ((score / total) * 100).round() : 0;
          isPassed = pct >= passingScore;
        }

        if (isPassed) {
          result[lesson.id] = LessonLockStatus(
            isUnlocked: true,
            isCompleted: isCompleted,
            isExamRequired: true,
            isExamPassed: true,
            requiredExam: prevExam,
            previousLessonTitle: prevLesson.title,
            previousLesson: prevLesson,
          );
        } else {
          result[lesson.id] = LessonLockStatus(
            isUnlocked: false,
            isCompleted: isCompleted,
            isExamRequired: true,
            isExamPassed: false,
            lockReason: sub != null
                ? 'يجب إعادة واجتياز امتحان الحصة السابقة (${prevLesson.title})'
                : 'يجب أداء واجتياز امتحان الحصة السابقة (${prevLesson.title}) أولاً',
            requiredExam: prevExam,
            previousLessonTitle: prevLesson.title,
            previousLesson: prevLesson,
          );
        }
      } else {
        // Previous lesson does NOT have an exam — just require attending it
        if (isPrevCompleted) {
          result[lesson.id] = LessonLockStatus(
            isUnlocked: true,
            isCompleted: isCompleted,
            previousLessonTitle: prevLesson.title,
            previousLesson: prevLesson,
          );
        } else {
          result[lesson.id] = LessonLockStatus(
            isUnlocked: false,
            isCompleted: isCompleted,
            lockReason: 'يجب مشاهدة الحصة السابقة (${prevLesson.title}) أولاً',
            previousLessonTitle: prevLesson.title,
            previousLesson: prevLesson,
          );
        }
      }
    }

    return result;
  }
}
