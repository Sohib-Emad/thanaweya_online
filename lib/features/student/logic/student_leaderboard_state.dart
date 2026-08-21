import 'package:thanaweya_online/features/student/data/repos/student_leaderboard_repo.dart';

enum LeaderboardStatus { initial, loading, loaded, error }

enum LeaderboardTimeframe { weekly, monthly, allTime }

class StudentLeaderboardState {
  final LeaderboardStatus status;
  final LeaderboardTimeframe timeframe;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? myEntry;
  final String? errorMessage;

  const StudentLeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.timeframe = LeaderboardTimeframe.weekly,
    this.entries = const [],
    this.myEntry,
    this.errorMessage,
  });

  // Whether at least one student has points
  bool get hasPoints => entries.any((e) => e.totalScore > 0);

  // Students who have scored points (> 0)
  List<LeaderboardEntry> get entriesWithPoints =>
      entries.where((e) => e.totalScore > 0).toList();

  // Only students with points can appear on the honor podium (Top 3)
  List<LeaderboardEntry> get topThree =>
      entriesWithPoints.take(3).toList();

  // The rest of the students (not on the podium)
  List<LeaderboardEntry> get restOfLeaderboard {
    final topIds = topThree.map((e) => e.studentId).toSet();
    return entries.where((e) => !topIds.contains(e.studentId)).toList();
  }

  StudentLeaderboardState copyWith({
    LeaderboardStatus? status,
    LeaderboardTimeframe? timeframe,
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? myEntry,
    String? errorMessage,
  }) {
    return StudentLeaderboardState(
      status: status ?? this.status,
      timeframe: timeframe ?? this.timeframe,
      entries: entries ?? this.entries,
      myEntry: myEntry ?? this.myEntry,
      errorMessage: errorMessage,
    );
  }
}
