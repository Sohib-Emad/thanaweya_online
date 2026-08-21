import 'package:thanaweya_online/features/student/data/repos/student_rewards_repo.dart';

enum StudentRewardsStatus { initial, loading, loaded, claiming, error }

class StudentRewardsState {
  final StudentRewardsStatus status;
  final StudentPointsSummary? summary;
  final List<PointMission> missions;
  final bool justClaimedDaily;
  final String? errorMessage;

  const StudentRewardsState({
    this.status = StudentRewardsStatus.initial,
    this.summary,
    this.missions = const [],
    this.justClaimedDaily = false,
    this.errorMessage,
  });

  int get totalPoints => summary?.totalPoints ?? 0;
  bool get canClaimDaily => summary?.canClaimDaily ?? true;

  StudentRewardsState copyWith({
    StudentRewardsStatus? status,
    StudentPointsSummary? summary,
    List<PointMission>? missions,
    bool? justClaimedDaily,
    String? errorMessage,
  }) {
    return StudentRewardsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      missions: missions ?? this.missions,
      justClaimedDaily: justClaimedDaily ?? this.justClaimedDaily,
      errorMessage: errorMessage,
    );
  }
}
