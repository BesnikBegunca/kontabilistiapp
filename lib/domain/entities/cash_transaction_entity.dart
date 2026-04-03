import 'package:equatable/equatable.dart';
import 'enums.dart';

class CashTransactionEntity extends Equatable {
  final int? id;
  final String? referenceNo;
  final TransactionDirection direction;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashTransactionEntity({
    this.id,
    this.referenceNo,
    required this.direction,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, referenceNo, direction, amount, description, transactionDate, createdAt, updatedAt];
}
