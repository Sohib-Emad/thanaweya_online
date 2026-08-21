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

  // Show all students (including those with 0 points)
  bool get hasEntries => entries.isNotEmpty;

  // Keep hasPoints for backward compat but don't use it to gate rendering
  bool get hasPoints => entries.any((e) => e.totalScore > 0);

  // Top 3 from ALL entries (sorted by score already)
  List<LeaderboardEntry> get topThree => entries.take(3).toList();

  // Rest of leaderboard after top 3
  List<LeaderboardEntry> get restOfLeaderboard =>
      entries.length > 3 ? entries.sublist(3) : const [];

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
