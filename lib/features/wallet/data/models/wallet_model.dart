import '../../domain/entities/wallet_entity.dart';
import 'wallet_transaction_model.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    super.currentBalance = 0.0,
    super.totalRecharged = 0.0,
    super.totalSpent = 0.0,
    super.transactions = const [],
  });

  factory WalletModel.fromData({
    required double balance,
    required List<WalletTransactionModel> transactions,
  }) {
    double recharged = 0.0;
    double spent = 0.0;

    for (final tx in transactions) {
      if (tx.isCredit) {
        recharged += tx.amount;
      } else if (tx.isDebit) {
        spent += tx.amount;
      }
    }

    return WalletModel(
      currentBalance: balance,
      totalRecharged: recharged,
      totalSpent: spent,
      transactions: transactions,
    );
  }
}
