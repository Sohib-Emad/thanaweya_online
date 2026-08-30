import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl(),
        super(const WalletState());

  String? _resolveUserId(String? candidate) {
    if (candidate != null && candidate.isNotEmpty) return candidate;
    return Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
  }

  void toggleBalanceVisibility() {
    emit(state.copyWith(isBalanceVisible: !state.isBalanceVisible));
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  Future<void> loadWallet([String? userId]) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: 'لم يتم العثور على حساب الطالب المسجل',
      ));
      return;
    }

    emit(state.copyWith(status: WalletStatus.loading, clearMessages: true));

    try {
      final data = await _repository.getWalletData(uid);
      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<bool> rechargeWithCard(String cardCode, [String? userId]) async {
    if (state.isRecharging) return false;

    final uid = _resolveUserId(userId);
    if (uid == null) {
      emit(state.copyWith(
        errorMessage: 'يرجى تسجيل الدخول أولاً لإتمام الشحن',
      ));
      return false;
    }

    emit(state.copyWith(isRecharging: true, clearMessages: true));

    try {
      final updatedWallet = await _repository.rechargeWithCard(
        userId: uid,
        cardCode: cardCode,
      );

      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: updatedWallet,
        isRecharging: false,
        successMessage: 'تم شحن رصيد الخزنة بنجاح! رصيدك الحالي: ${updatedWallet.currentBalance.toStringAsFixed(2)} ج.م',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isRecharging: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> purchaseCourse({
    required String courseId,
    required String teacherId,
    required double price,
    required String courseTitle,
    String? userId,
  }) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      emit(state.copyWith(errorMessage: 'يرجى تسجيل الدخول أولاً لإتمام الشراء'));
      return false;
    }

    emit(state.copyWith(isPurchasing: true, clearMessages: true));

    try {
      final ok = await _repository.purchaseCourse(
        userId: uid,
        courseId: courseId,
        teacherId: teacherId,
        price: price,
        courseTitle: courseTitle,
      );

      if (ok) {
        final updatedWallet = await _repository.getWalletData(uid);
        emit(state.copyWith(
          status: WalletStatus.loaded,
          wallet: updatedWallet,
          isPurchasing: false,
          successMessage: 'تم شراء الكورس بنجاح وتفعيله على حسابك!',
        ));
        return true;
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: 'تعذر إتمام عملية الشراء، يرجى المحاولة مرة أخرى',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        isPurchasing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }
}
