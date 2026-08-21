import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_leaderboard_repo.dart';
import 'student_leaderboard_state.dart';
export 'student_leaderboard_state.dart';

class StudentLeaderboardCubit extends Cubit<StudentLeaderboardState> {
  final StudentLeaderboardRepo _repo;

  StudentLeaderboardCubit({StudentLeaderboardRepo? repo})
      : _repo = repo ?? StudentLeaderboardRepo(),
        super(const StudentLeaderboardState());

  @override
  void emit(StudentLeaderboardState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadLeaderboard([LeaderboardTimeframe? timeframe]) async {
    final selectedTimeframe = timeframe ?? state.timeframe;
    emit(state.copyWith(
      status: LeaderboardStatus.loading,
      timeframe: selectedTimeframe,
    ));

    final tfKey = switch (selectedTimeframe) {
      LeaderboardTimeframe.weekly => 'weekly',
      LeaderboardTimeframe.monthly => 'monthly',
      LeaderboardTimeframe.allTime => 'all_time',
    };

    final result = await _repo.getLeaderboard(timeframe: tfKey);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    result.when(
      success: (entries) {
        LeaderboardEntry? myEntry;
        if (currentUserId != null) {
          try {
            myEntry = entries.firstWhere((e) => e.studentId == currentUserId);
          } catch (_) {
            myEntry = null;
          }
        }
        emit(state.copyWith(
          status: LeaderboardStatus.loaded,
          entries: entries,
          myEntry: myEntry,
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        status: LeaderboardStatus.error,
        errorMessage: message,
      )),
    );
  }

  void switchTimeframe(LeaderboardTimeframe timeframe) {
    if (state.timeframe == timeframe) return;
    loadLeaderboard(timeframe);
  }
}
