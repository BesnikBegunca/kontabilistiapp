import 'package:equatable/equatable.dart';
import 'enums.dart';

class ExpenseCategoryEntity extends Equatable {
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseCategoryEntity({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}

class ExpenseEntity extends Equatable {
  final int? id;
  final int? categoryId;
  final ExpenseType expenseType;
  final double amount;
  final DateTime expenseDate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    this.id,
    this.categoryId,
    required this.expenseType,
    required this.amount,
    required this.expenseDate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, categoryId, expenseType, amount, expenseDate, description, createdAt, updatedAt];
}
