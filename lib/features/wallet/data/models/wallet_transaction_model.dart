import '../../domain/entities/wallet_transaction_entity.dart';

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.userId,
    required super.title,
    super.subtitle,
    required super.amount,
    required super.type,
    super.status,
    super.referenceId,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String? ?? 'credit').toLowerCase();
    final type = rawType == 'debit'
        ? WalletTransactionType.debit
        : WalletTransactionType.credit;

    final rawAmount = json['amount'];
    final double amount = (rawAmount is num)
        ? rawAmount.toDouble()
        : (double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0);

    final rawDate = json['created_at'];
    DateTime createdAt;
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] as String? ?? 'معاملة مالية',
      subtitle: json['subtitle'] as String?,
      amount: amount,
      type: type,
      status: json['status'] as String? ?? 'completed',
      referenceId: json['reference_id']?.toString(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type == WalletTransactionType.credit ? 'credit' : 'debit',
      'status': status,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
