import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_push_tokens_repo.dart';

enum AdminPushTokensStatus { initial, loading, loaded, error }
enum AdminNotificationSendStatus { initial, sending, sent, error }

class AdminPushTokensState {
  final AdminPushTokensStatus status;
  final AdminNotificationSendStatus sendStatus;
  final List<Map<String, dynamic>> allTokens;
  final List<Map<String, dynamic>> filteredTokens;
  final String roleFilter; // 'all', 'student', 'teacher'
  final String platformFilter; // 'all', 'android', 'ios'
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

class AdminPushTokensCubit extends Cubit<AdminPushTokensState> {
  final AdminPushTokensRepo _repo;

  AdminPushTokensCubit({AdminPushTokensRepo? repo})
      : _repo = repo ?? AdminPushTokensRepo(),
        super(const AdminPushTokensState());

  Future<void> loadTokens() async {
    emit(state.copyWith(status: AdminPushTokensStatus.loading));
    final result = await _repo.getAllDeviceTokens();
    result.when(
      success: (tokens) {
        final filtered = _applyFilters(
          tokens: tokens,
          role: state.roleFilter,
          platform: state.platformFilter,
          query: state.searchQuery,
        );
        emit(state.copyWith(
          status: AdminPushTokensStatus.loaded,
          allTokens: tokens,
          filteredTokens: filtered,
        ));
      },
      failure: (msg, _) => emit(state.copyWith(
        status: AdminPushTokensStatus.error,
        errorMessage: msg,
      )),
    );
  }

  void filterByRole(String role) {
    final filtered = _applyFilters(
      tokens: state.allTokens,
      role: role,
      platform: state.platformFilter,
      query: state.searchQuery,
    );
    emit(state.copyWith(
      roleFilter: role,
      filteredTokens: filtered,
    ));
  }

  void filterByPlatform(String platform) {
    final filtered = _applyFilters(
      tokens: state.allTokens,
      role: state.roleFilter,
      platform: platform,
      query: state.searchQuery,
    );
    emit(state.copyWith(
      platformFilter: platform,
      filteredTokens: filtered,
    ));
  }

  void search(String query) {
    final filtered = _applyFilters(
      tokens: state.allTokens,
      role: state.roleFilter,
      platform: state.platformFilter,
      query: query,
    );
    emit(state.copyWith(
      searchQuery: query,
      filteredTokens: filtered,
    ));
  }

  List<Map<String, dynamic>> _applyFilters({
    required List<Map<String, dynamic>> tokens,
    required String role,
    required String platform,
    required String query,
  }) {
    var list = List<Map<String, dynamic>>.from(tokens);

    if (role != 'all') {
      list = list.where((t) => (t['role'] as String?) == role).toList();
    }

    if (platform != 'all') {
      list = list
          .where((t) =>
              (t['platform'] as String?)?.toLowerCase() ==
              platform.toLowerCase())
          .toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((t) {
        final name = (t['full_name'] as String? ?? '').toLowerCase();
        final email = (t['email'] as String? ?? '').toLowerCase();
        final token = (t['token'] as String? ?? '').toLowerCase();
        return name.contains(q) || email.contains(q) || token.contains(q);
      }).toList();
    }

    return list;
  }

  Future<bool> sendNotification({
    required String title,
    required String body,
    required String targetType,
    String? specificUserId,
    String category = 'admin_broadcast',
  }) async {
    emit(state.copyWith(sendStatus: AdminNotificationSendStatus.sending));
    final result = await _repo.sendNotification(
      title: title,
      body: body,
      targetType: targetType,
      specificUserId: specificUserId,
      category: category,
    );

    return result.when(
      success: (count) {
        emit(state.copyWith(
          sendStatus: AdminNotificationSendStatus.sent,
          sentCount: count,
        ));
        return true;
      },
      failure: (msg, _) {
        emit(state.copyWith(
          sendStatus: AdminNotificationSendStatus.error,
          errorMessage: msg,
        ));
        return false;
      },
    );
  }

  Future<void> deleteToken(String tokenId) async {
    final result = await _repo.deleteDeviceToken(tokenId);
    result.when(
      success: (_) {
        final updatedAll =
            state.allTokens.where((t) => t['id'] != tokenId).toList();
        final updatedFiltered =
            state.filteredTokens.where((t) => t['id'] != tokenId).toList();
        emit(state.copyWith(
          allTokens: updatedAll,
          filteredTokens: updatedFiltered,
        ));
      },
      failure: (msg, _) => emit(state.copyWith(errorMessage: msg)),
    );
  }
}
