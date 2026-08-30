import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_push_tokens_repo.dart';

part 'admin_push_tokens_state.dart';

class AdminPushTokensCubit extends Cubit<AdminPushTokensState> {
  final AdminPushTokensRepo _repo;

  AdminPushTokensCubit({AdminPushTokensRepo? repo})
      : _repo = repo ?? AdminPushTokensRepo(),
        super(const AdminPushTokensState());

  Future<void> loadTokens() async {
    emit(state.copyWith(status: AdminPushTokensStatus.loading));
    final result = await _repo.getAllDeviceTokens();
    result.when(
      success: (tokens) => emit(state.copyWith(
        status: AdminPushTokensStatus.loaded,
        allTokens: tokens,
        filteredTokens: _applyFilters(tokens, state.roleFilter, state.platformFilter, state.searchQuery),
      )),
      failure: (msg, _) => emit(state.copyWith(status: AdminPushTokensStatus.error, errorMessage: msg)),
    );
  }

  void filterByRole(String role) => emit(state.copyWith(
        roleFilter: role,
        filteredTokens: _applyFilters(state.allTokens, role, state.platformFilter, state.searchQuery),
      ));

  void filterByPlatform(String platform) => emit(state.copyWith(
        platformFilter: platform,
        filteredTokens: _applyFilters(state.allTokens, state.roleFilter, platform, state.searchQuery),
      ));

  void search(String query) => emit(state.copyWith(
        searchQuery: query,
        filteredTokens: _applyFilters(state.allTokens, state.roleFilter, state.platformFilter, query),
      ));

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> tokens, String role, String platform, String query) {
    var list = List<Map<String, dynamic>>.from(tokens);
    if (role != 'all') list = list.where((t) => (t['role'] as String?) == role).toList();
    if (platform != 'all') {
      list = list.where((t) => (t['platform'] as String?)?.toLowerCase() == platform.toLowerCase()).toList();
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
        emit(state.copyWith(sendStatus: AdminNotificationSendStatus.sent, sentCount: count));
        return true;
      },
      failure: (msg, _) {
        emit(state.copyWith(sendStatus: AdminNotificationSendStatus.error, errorMessage: msg));
        return false;
      },
    );
  }

  Future<void> deleteToken(String tokenId) async {
    final result = await _repo.deleteDeviceToken(tokenId);
    result.when(
      success: (_) => emit(state.copyWith(
        allTokens: state.allTokens.where((t) => t['id'] != tokenId).toList(),
        filteredTokens: state.filteredTokens.where((t) => t['id'] != tokenId).toList(),
      )),
      failure: (msg, _) => emit(state.copyWith(errorMessage: msg)),
    );
  }
}
