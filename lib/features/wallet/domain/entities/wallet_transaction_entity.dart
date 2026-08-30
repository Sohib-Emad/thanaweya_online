import 'package:equatable/equatable.dart';

enum WalletTransactionType {
  credit, // إيداع / شحن
  debit,  // خصم / شراء
}

class WalletTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? subtitle;
  final double amount;
  final WalletTransactionType type;
  final String status;
  final String? referenceId;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.type,
    this.status = 'completed',
    this.referenceId,
    required this.createdAt,
  });

  bool get isCredit => type == WalletTransactionType.credit;
  bool get isDebit => type == WalletTransactionType.debit;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        subtitle,
        amount,
        type,
        status,
        referenceId,
        createdAt,
      ];
}
