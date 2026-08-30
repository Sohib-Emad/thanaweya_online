import 'package:equatable/equatable.dart';
import 'wallet_transaction_entity.dart';

class WalletEntity extends Equatable {
  final double currentBalance;
  final double totalRecharged;
  final double totalSpent;
  final List<WalletTransactionEntity> transactions;

  const WalletEntity({
    this.currentBalance = 0.0,
    this.totalRecharged = 0.0,
    this.totalSpent = 0.0,
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [
        currentBalance,
        totalRecharged,
        totalSpent,
        transactions,
      ];
}
