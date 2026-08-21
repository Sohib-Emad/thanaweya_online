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

  /// Fetches ALL students registered on the platform ranked by score.
  /// Uses `get_leaderboard` RPC (SECURITY DEFINER) to bypass RLS.
  /// Falls back to partial data if the RPC is not deployed yet.
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

      // ─── Primary: RPC call (bypasses RLS, returns all students) ─────────
      try {
        final rpcResult = await _client.rpc(
          'get_leaderboard',
          params: {'p_since': sinceDate?.toIso8601String()},
        );

        final rows = rpcResult as List;
        debugPrint('[StudentLeaderboardRepo] RPC returned ${rows.length} students');

        final entries = <LeaderboardEntry>[];
        for (int i = 0; i < rows.length; i++) {
          final row = Map<String, dynamic>.from(rows[i] as Map);
          entries.add(LeaderboardEntry.fromMap(row, i + 1));
        }
        return ApiResult.success(entries);
      } catch (rpcError) {
        debugPrint('[StudentLeaderboardRepo] RPC failed, using fallback: $rpcError');
      }

      // ─── Fallback: Build from own data + exam_submissions ────────────────
      final studentsMap = <String, Map<String, dynamic>>{};

      // Add current user (readable via RLS)
      final currentUid = _client.auth.currentUser?.id ??
          _client.auth.currentSession?.user.id;
      if (currentUid != null) {
        try {
          final myStudent = await _client
              .from('students')
              .select('id, grade_level, bonus_points')
              .eq('id', currentUid)
              .maybeSingle();
          if (myStudent != null) {
            final myUser = await _client
                .from('users')
                .select('id, full_name, avatar_url')
                .eq('id', currentUid)
                .maybeSingle();
            final fullName = (myUser?['full_name'] as String?)?.trim() ?? '';
            studentsMap[currentUid] = {
              'student_id': currentUid,
              'full_name': fullName.isEmpty ? 'طالب' : fullName,
              'avatar_url': myUser?['avatar_url']?.toString(),
              'grade_level': myStudent['grade_level']?.toString(),
              'teacher_name': null,
              'total_score': (myStudent['bonus_points'] as num?)?.toInt() ?? 0,
              'exams_completed': 0,
            };
          }
        } catch (_) {}
      }

      // Aggregate exam submissions (all authenticated can read submissions)
      try {
        var query = _client
            .from('exam_submissions')
            .select('student_id, score, submitted_at')
            .not('submitted_at', 'is', null);

        if (sinceDate != null) {
          query = query.gte('submitted_at', sinceDate.toIso8601String());
        }

        final submissions = await query;
        for (final sub in (submissions as List)) {
          final sId = sub['student_id']?.toString();
          if (sId == null || sId.isEmpty) continue;
          final score = (sub['score'] as num?)?.toInt() ?? 0;

          if (studentsMap.containsKey(sId)) {
            studentsMap[sId]!['total_score'] =
                (studentsMap[sId]!['total_score'] as int) + score;
            studentsMap[sId]!['exams_completed'] =
                (studentsMap[sId]!['exams_completed'] as int) + 1;
          } else {
            studentsMap[sId] = {
              'student_id': sId,
              'full_name': 'طالب',
              'avatar_url': null,
              'grade_level': null,
              'teacher_name': null,
              'total_score': score,
              'exams_completed': 1,
            };
          }
        }
      } catch (e) {
        debugPrint('[StudentLeaderboardRepo] Submissions fallback error: $e');
      }

      // Fetch teacher names from subscriptions
      try {
        final subs = await _client
            .from('subscriptions')
            .select('student_id, teachers(users(full_name))');
        for (final sub in (subs as List)) {
          final sId = sub['student_id']?.toString();
          if (sId == null || !studentsMap.containsKey(sId)) continue;
          final tObj = sub['teachers'] as Map<String, dynamic>?;
          final uObj = tObj?['users'] as Map<String, dynamic>?;
          final tName = uObj?['full_name']?.toString().trim();
          if (tName != null && tName.isNotEmpty) {
            final existing = studentsMap[sId]!['teacher_name'] as String?;
            studentsMap[sId]!['teacher_name'] = existing == null
                ? 'أ. $tName'
                : (existing.contains(tName) ? existing : '$existing، أ. $tName');
          }
        }
      } catch (_) {}

      final sortedList = studentsMap.values.toList()
        ..sort((a, b) {
          final scoreComp =
              (b['total_score'] as int).compareTo(a['total_score'] as int);
          if (scoreComp != 0) return scoreComp;
          final examComp = (b['exams_completed'] as int)
              .compareTo(a['exams_completed'] as int);
          if (examComp != 0) return examComp;
          return (a['full_name'] as String).compareTo(b['full_name'] as String);
        });

      final entries = <LeaderboardEntry>[];
      for (int i = 0; i < sortedList.length; i++) {
        entries.add(LeaderboardEntry.fromMap(sortedList[i], i + 1));
      }

      debugPrint('[StudentLeaderboardRepo] Fallback loaded: ${entries.length} students');
      return ApiResult.success(entries);
    } catch (e) {
      debugPrint('[StudentLeaderboardRepo] Error fetching leaderboard: $e');
      return ApiErrorHandler.handleException(e);
    }
  }
}

