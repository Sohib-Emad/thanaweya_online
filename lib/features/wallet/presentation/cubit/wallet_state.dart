import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';

enum WalletStatus {
  initial,
  loading,
  loaded,
  error,
}

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletEntity wallet;
  final String? errorMessage;
  final String? successMessage;
  final bool isRecharging;
  final bool isPurchasing;
  final bool isBalanceVisible;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet = const WalletEntity(),
    this.errorMessage,
    this.successMessage,
    this.isRecharging = false,
    this.isPurchasing = false,
    this.isBalanceVisible = true,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletEntity? wallet,
    String? errorMessage,
    String? successMessage,
    bool? isRecharging,
    bool? isPurchasing,
    bool? isBalanceVisible,
    bool clearMessages = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      isRecharging: isRecharging ?? this.isRecharging,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }

  @override
  List<Object?> get props => [
        status,
        wallet,
        errorMessage,
        successMessage,
        isRecharging,
        isPurchasing,
        isBalanceVisible,
      ];
}
