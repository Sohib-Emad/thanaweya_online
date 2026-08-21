import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Data model representing a student's point mission/task.
class PointMission {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final String iconEmoji;
  final bool isCompleted;
  final int currentProgress;
  final int targetProgress;
  final String? routeToOpen;

  const PointMission({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.iconEmoji,
    this.isCompleted = false,
    this.currentProgress = 0,
    this.targetProgress = 1,
    this.routeToOpen,
  });
}

/// Points summary model for a student.
class StudentPointsSummary {
  final int totalPoints;
  final int examPoints;
  final int bonusPoints;
  final int examsCompleted;
  final int lessonsCompleted;
  final bool canClaimDaily;
  final DateTime? lastDailyClaimAt;

  const StudentPointsSummary({
    required this.totalPoints,
    required this.examPoints,
    required this.bonusPoints,
    required this.examsCompleted,
    required this.lessonsCompleted,
    required this.canClaimDaily,
    this.lastDailyClaimAt,
  });

  String get tierName {
    if (totalPoints >= 500) return 'أسطوري 👑';
    if (totalPoints >= 250) return 'ذهبي 🥇';
    if (totalPoints >= 100) return 'فضي 🥈';
    if (totalPoints >= 30) return 'برونزي 🥉';
    return 'مبتدئ 🚀';
  }

  int get nextTierThreshold {
    if (totalPoints < 30) return 30;
    if (totalPoints < 100) return 100;
    if (totalPoints < 250) return 250;
    if (totalPoints < 500) return 500;
    return 1000;
  }
}

/// Repository responsible for student rewards, daily claims, and points accumulation.
class StudentRewardsRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches the points summary for a student.
  Future<ApiResult<StudentPointsSummary>> getPointsSummary(
    String studentId,
  ) async {
    try {
      // 1. Fetch student info (bonus_points, last_daily_claim_at)
      int bonusPoints = 0;
      DateTime? lastDailyClaimAt;

      try {
        final sData = await _client
            .from('students')
            .select('bonus_points, last_daily_claim_at')
            .eq('id', studentId)
            .maybeSingle();

        if (sData != null) {
          bonusPoints = (sData['bonus_points'] as num?)?.toInt() ?? 0;
          final lastClaimStr = sData['last_daily_claim_at']?.toString();
          if (lastClaimStr != null) {
            lastDailyClaimAt = DateTime.tryParse(lastClaimStr);
          }
        }
      } catch (e) {
        debugPrint('[StudentRewardsRepo] students bonus_points fetch note: $e');
      }

      // 2. Fetch exam submissions points & count (only completed — submitted_at IS NOT NULL)
      int examPoints = 0;
      int examsCompleted = 0;
      try {
        final submissions = await _client
            .from('exam_submissions')
            .select('score')
            .eq('student_id', studentId)
            .not('submitted_at', 'is', null); // ← skip in-progress rows (score=0)

        for (final sub in (submissions as List)) {
          final sc = (sub['score'] as num?)?.toInt() ?? 0;
          examPoints += sc;
          examsCompleted++;
        }
      } catch (e) {
        debugPrint('[StudentRewardsRepo] exam_submissions points fetch error: $e');
      }

      // 3. Fetch completed lessons count
      int lessonsCompleted = 0;
      try {
        final progressData = await _client
            .from('lesson_progress')
            .select('is_completed')
            .eq('student_id', studentId)
            .eq('is_completed', true);
        lessonsCompleted = (progressData as List).length;
      } catch (e) {
        debugPrint('[StudentRewardsRepo] lesson_progress count error: $e');
      }

      // Determine if daily reward can be claimed today
      bool canClaimDaily = true;
      if (lastDailyClaimAt != null) {
        final now = DateTime.now();
        final isSameDay = lastDailyClaimAt.year == now.year &&
            lastDailyClaimAt.month == now.month &&
            lastDailyClaimAt.day == now.day;
        canClaimDaily = !isSameDay;
      }

      final totalPoints = examPoints + bonusPoints + (lessonsCompleted * 5);

      return ApiResult.success(
        StudentPointsSummary(
          totalPoints: totalPoints,
          examPoints: examPoints,
          bonusPoints: bonusPoints,
          examsCompleted: examsCompleted,
          lessonsCompleted: lessonsCompleted,
          canClaimDaily: canClaimDaily,
          lastDailyClaimAt: lastDailyClaimAt,
        ),
      );
    } catch (e) {
      debugPrint('[StudentRewardsRepo] getPointsSummary error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Claims the 5 daily check-in points for the student.
  Future<ApiResult<int>> claimDailyReward(String studentId) async {
    try {
      final now = DateTime.now();
      // Try to increment bonus_points by 5 and update last_daily_claim_at
      int currentBonus = 0;
      try {
        final current = await _client
            .from('students')
            .select('bonus_points')
            .eq('id', studentId)
            .maybeSingle();
        currentBonus = (current?['bonus_points'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      final newBonus = currentBonus + 5;

      try {
        await _client.from('students').update({
          'bonus_points': newBonus,
          'last_daily_claim_at': now.toIso8601String(),
        }).eq('id', studentId);
      } catch (e) {
        debugPrint('[StudentRewardsRepo] fallback updating student bonus: $e');
      }

      return const ApiResult.success(5);
    } catch (e) {
      debugPrint('[StudentRewardsRepo] claimDailyReward error: $e');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Generates the list of interactive missions with current student progress.
  List<PointMission> getMissions(StudentPointsSummary summary) {
    return [
      PointMission(
        id: 'daily_login',
        title: 'تسجيل الدخول اليومي',
        description: 'ادخل التطبيق يومياً واستلم هديتك المجانية',
        pointsReward: 5,
        iconEmoji: '🎁',
        isCompleted: !summary.canClaimDaily,
        currentProgress: !summary.canClaimDaily ? 1 : 0,
        targetProgress: 1,
      ),
      PointMission(
        id: 'solve_exam',
        title: 'حل اختبار إلكتروني',
        description: 'اختبر مستواك في أي مادة واكسب نقاط إضافية',
        pointsReward: 20,
        iconEmoji: '📝',
        isCompleted: summary.examsCompleted > 0,
        currentProgress: summary.examsCompleted,
        targetProgress: 1,
        routeToOpen: '/student/exams',
      ),
      PointMission(
        id: 'watch_lesson',
        title: 'إتمام مشاهدة درس',
        description: 'شاهد أي درس تعليمي بالكامل حتى النهاية',
        pointsReward: 10,
        iconEmoji: '🎬',
        isCompleted: summary.lessonsCompleted > 0,
        currentProgress: summary.lessonsCompleted,
        targetProgress: 1,
        routeToOpen: '/student/my-courses',
      ),
      PointMission(
        id: 'exam_streak',
        title: 'بطل الاختبارات (3 امتحانات)',
        description: 'أكمل حل 3 امتحانات مختلفة بتفوق',
        pointsReward: 50,
        iconEmoji: '🔥',
        isCompleted: summary.examsCompleted >= 3,
        currentProgress: summary.examsCompleted.clamp(0, 3),
        targetProgress: 3,
        routeToOpen: '/student/exams',
      ),
      PointMission(
        id: 'course_master',
        title: 'إتمام كورس كامل',
        description: 'أنهِ جميع دروس كورس تعليمي بنجاح',
        pointsReward: 50,
        iconEmoji: '🎓',
        isCompleted: summary.lessonsCompleted >= 5,
        currentProgress: summary.lessonsCompleted.clamp(0, 5),
        targetProgress: 5,
        routeToOpen: '/student/my-courses',
      ),
    ];
  }
}
