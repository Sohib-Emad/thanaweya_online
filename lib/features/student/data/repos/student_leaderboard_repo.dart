import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Data model representing a student on the leaderboard.
class LeaderboardEntry {
  final String studentId;
  final String fullName;
  final String? avatarUrl;
  final String? gradeLevel;
  final String? teacherName;
  final int totalScore;
  final int examsCompleted;
  final int rank;

  const LeaderboardEntry({
    required this.studentId,
    required this.fullName,
    this.avatarUrl,
    this.gradeLevel,
    this.teacherName,
    required this.totalScore,
    required this.examsCompleted,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      studentId: map['student_id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? 'طالب',
      avatarUrl: map['avatar_url']?.toString(),
      gradeLevel: map['grade_level']?.toString(),
      teacherName: map['teacher_name']?.toString(),
      totalScore: (map['total_score'] as num?)?.toInt() ?? 0,
      examsCompleted: (map['exams_completed'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}

/// Repository responsible for aggregating and fetching all platform students,
/// their teachers, and their exam scores.
class StudentLeaderboardRepo {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches ALL students registered on the platform ranked by score,
  /// including teacher names and students with lower/zero points.
  Future<ApiResult<List<LeaderboardEntry>>> getLeaderboard({
    String timeframe = 'all_time',
  }) async {
    try {
      DateTime? sinceDate;
      final now = DateTime.now();
      if (timeframe == 'weekly') {
        sinceDate = now.subtract(const Duration(days: 7));
      } else if (timeframe == 'monthly') {
        sinceDate = now.subtract(const Duration(days: 30));
      }

      // ─── 1. Fetch All Students ──────────────────────────────────────────
      final studentsMap = <String, Map<String, dynamic>>{};
      try {
        final studentsData = await _client.from('students').select(
              'id, grade_level, bonus_points, users(id, full_name, avatar_url)',
            );

        for (final s in (studentsData as List)) {
          final sId = s['id']?.toString();
          if (sId == null || sId.isEmpty) continue;

          final u = s['users'] as Map<String, dynamic>?;
          final fullName = u?['full_name']?.toString().trim() ?? '';
          final avatarUrl = u?['avatar_url']?.toString();
          final gradeLevel = s['grade_level']?.toString();
          final bonus = (s['bonus_points'] as num?)?.toInt() ?? 0;

          studentsMap[sId] = {
            'student_id': sId,
            'full_name': fullName.isEmpty ? 'طالب' : fullName,
            'avatar_url': avatarUrl,
            'grade_level': gradeLevel,
            'teacher_name': null,
            'total_score': bonus,
            'exams_completed': 0,
          };
        }
      } catch (e) {
        debugPrint('[StudentLeaderboardRepo] Direct join query error: $e');
        // Fallback: fetch students and users separately
        try {
          final sList = await _client.from('students').select('id, grade_level, bonus_points');
          final uList = await _client.from('users').select('id, full_name, avatar_url');
          final usersById = {for (final u in (uList as List)) (u['id']?.toString() ?? ''): u};

          for (final s in (sList as List)) {
            final sId = s['id']?.toString();
            if (sId == null || sId.isEmpty) continue;
            final u = usersById[sId];
            final fullName = u?['full_name']?.toString().trim() ?? '';
            final bonus = (s['bonus_points'] as num?)?.toInt() ?? 0;
            studentsMap[sId] = {
              'student_id': sId,
              'full_name': fullName.isEmpty ? 'طالب' : fullName,
              'avatar_url': u?['avatar_url']?.toString(),
              'grade_level': s['grade_level']?.toString(),
              'teacher_name': null,
              'total_score': bonus,
              'exams_completed': 0,
            };
          }
        } catch (_) {}
      }

      // ─── 2. Fetch Teachers for Subscribed Students ───────────────────────
      try {
        final subs = await _client
            .from('subscriptions')
            .select('student_id, teacher_id, teachers(users(full_name))');

        for (final sub in (subs as List)) {
          final sId = sub['student_id']?.toString();
          if (sId == null || !studentsMap.containsKey(sId)) continue;

          final tObj = sub['teachers'] as Map<String, dynamic>?;
          final uObj = tObj?['users'] as Map<String, dynamic>?;
          final tName = uObj?['full_name']?.toString().trim();

          if (tName != null && tName.isNotEmpty) {
            final existing = studentsMap[sId]!['teacher_name'] as String?;
            if (existing == null) {
              studentsMap[sId]!['teacher_name'] = 'أ. $tName';
            } else if (!existing.contains(tName)) {
              studentsMap[sId]!['teacher_name'] = '$existing، أ. $tName';
            }
          }
        }
      } catch (e) {
        debugPrint('[StudentLeaderboardRepo] Subscriptions fetch note: $e');
      }

      // ─── 3. Fetch and Aggregate Exam Scores (completed only) ─────────────
      try {
        var query = _client
            .from('exam_submissions')
            .select('student_id, score, submitted_at')
            .not('submitted_at', 'is', null); // ← skip in-progress rows

        if (sinceDate != null) {
          query = query.gte('submitted_at', sinceDate.toIso8601String());
        }

        final submissions = await query;
        for (final sub in (submissions as List)) {
          final sId = sub['student_id']?.toString();
          if (sId == null || sId.isEmpty) continue;

          final score = (sub['score'] as num?)?.toInt() ?? 0;

          if (studentsMap.containsKey(sId)) {
            final sEntry = studentsMap[sId]!;
            sEntry['total_score'] = (sEntry['total_score'] as int) + score;
            sEntry['exams_completed'] =
                (sEntry['exams_completed'] as int) + 1;
          }
        }
      } catch (e) {
        debugPrint('[StudentLeaderboardRepo] Submissions fetch note: $e');
      }

      // ─── 4. Sort All Students (Highest to Lowest) ────────────────────────
      final sortedList = studentsMap.values.toList()
        ..sort((a, b) {
          final scoreComp =
              (b['total_score'] as int).compareTo(a['total_score'] as int);
          if (scoreComp != 0) return scoreComp;
          final examComp = (b['exams_completed'] as int)
              .compareTo(a['exams_completed'] as int);
          if (examComp != 0) return examComp;
          return (a['full_name'] as String)
              .compareTo(b['full_name'] as String);
        });

      // ─── 5. Map with Sequential Ranks ────────────────────────────────────
      final entries = <LeaderboardEntry>[];
      for (int i = 0; i < sortedList.length; i++) {
        entries.add(LeaderboardEntry.fromMap(sortedList[i], i + 1));
      }

      return ApiResult.success(entries);
    } catch (e) {
      debugPrint('[StudentLeaderboardRepo] Error fetching leaderboard: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}
