part of 'admin_push_tokens_cubit.dart';

enum AdminPushTokensStatus { initial, loading, loaded, error }
enum AdminNotificationSendStatus { initial, sending, sent, error }

class AdminPushTokensState {
  final AdminPushTokensStatus status;
  final AdminNotificationSendStatus sendStatus;
  final List<Map<String, dynamic>> allTokens;
  final List<Map<String, dynamic>> filteredTokens;
  final String roleFilter;
  final String platformFilter;
  final String searchQuery;
  final int sentCount;
  final String? errorMessage;

  const AdminPushTokensState({
    this.status = AdminPushTokensStatus.initial,
    this.sendStatus = AdminNotificationSendStatus.initial,
    this.allTokens = const [],
    this.filteredTokens = const [],
    this.roleFilter = 'all',
    this.platformFilter = 'all',
    this.searchQuery = '',
    this.sentCount = 0,
    this.errorMessage,
  });

  int get totalCount => allTokens.length;
  int get studentsCount => allTokens.where((t) => t['role'] == 'student').length;
  int get teachersCount => allTokens.where((t) => t['role'] == 'teacher').length;
  int get androidCount =>
      allTokens.where((t) => (t['platform'] as String?)?.toLowerCase() == 'android').length;
  int get iosCount =>
      allTokens.where((t) => (t['platform'] as String?)?.toLowerCase() == 'ios').length;

  AdminPushTokensState copyWith({
    AdminPushTokensStatus? status,
    AdminNotificationSendStatus? sendStatus,
    List<Map<String, dynamic>>? allTokens,
    List<Map<String, dynamic>>? filteredTokens,
    String? roleFilter,
    String? platformFilter,
    String? searchQuery,
    int? sentCount,
    String? errorMessage,
  }) {
    return AdminPushTokensState(
      status: status ?? this.status,
      sendStatus: sendStatus ?? this.sendStatus,
      allTokens: allTokens ?? this.allTokens,
      filteredTokens: filteredTokens ?? this.filteredTokens,
      roleFilter: roleFilter ?? this.roleFilter,
      platformFilter: platformFilter ?? this.platformFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      sentCount: sentCount ?? this.sentCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
