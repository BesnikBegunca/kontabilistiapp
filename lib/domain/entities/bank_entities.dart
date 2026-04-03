import 'package:equatable/equatable.dart';
import 'enums.dart';

class BankAccountEntity extends Equatable {
  final int? id;
  final String name;
  final String? iban;
  final String? bankName;
  final String currency;
  final double openingBalance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankAccountEntity({
    this.id,
    required this.name,
    this.iban,
    this.bankName,
    required this.currency,
    required this.openingBalance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, iban, bankName, currency, openingBalance, isActive, createdAt, updatedAt];
}

class BankTransactionEntity extends Equatable {
  final int? id;
  final int bankAccountId;
  final String? referenceNo;
  final TransactionDirection direction;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankTransactionEntity({
    this.id,
    required this.bankAccountId,
    this.referenceNo,
    required this.direction,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, bankAccountId, referenceNo, direction, amount, description, transactionDate, createdAt, updatedAt];
}
