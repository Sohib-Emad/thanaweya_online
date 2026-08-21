import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_rewards_repo.dart';
import 'student_rewards_state.dart';
export 'student_rewards_state.dart';

class StudentRewardsCubit extends Cubit<StudentRewardsState> {
  final StudentRewardsRepo _repo;

  StudentRewardsCubit({StudentRewardsRepo? repo})
      : _repo = repo ?? StudentRewardsRepo(),
        super(const StudentRewardsState());

  @override
  void emit(StudentRewardsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadRewards() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    emit(state.copyWith(status: StudentRewardsStatus.loading));
    final result = await _repo.getPointsSummary(userId);

    result.when(
      success: (summary) {
        final missions = _repo.getMissions(summary);
        emit(state.copyWith(
          status: StudentRewardsStatus.loaded,
          summary: summary,
          missions: missions,
          justClaimedDaily: false,
        ));
      },
      failure: (message, _) => emit(state.copyWith(
        status: StudentRewardsStatus.error,
        errorMessage: message,
      )),
    );
  }

  Future<bool> claimDailyGift() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || !state.canClaimDaily) return false;

    emit(state.copyWith(status: StudentRewardsStatus.claiming));
    final result = await _repo.claimDailyReward(userId);

    return result.when(
      success: (pointsEarned) {
        final old = state.summary;
        if (old != null) {
          final updatedSummary = StudentPointsSummary(
            totalPoints: old.totalPoints + pointsEarned,
            examPoints: old.examPoints,
            bonusPoints: old.bonusPoints + pointsEarned,
            examsCompleted: old.examsCompleted,
            lessonsCompleted: old.lessonsCompleted,
            canClaimDaily: false,
            lastDailyClaimAt: DateTime.now(),
          );
          final updatedMissions = _repo.getMissions(updatedSummary);
          emit(state.copyWith(
            status: StudentRewardsStatus.loaded,
            summary: updatedSummary,
            missions: updatedMissions,
            justClaimedDaily: true,
          ));
        } else {
          loadRewards();
        }
        return true;
      },
      failure: (message, _) {
        emit(state.copyWith(
          status: StudentRewardsStatus.error,
          errorMessage: message,
        ));
        return false;
      },
    );
  }
}
