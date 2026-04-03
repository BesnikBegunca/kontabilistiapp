import 'package:equatable/equatable.dart';
import 'enums.dart';

class PaymentEntity extends Equatable {
  final int? id;
  final String invoiceType;
  final int invoiceId;
  final DateTime paymentDate;
  final double amount;
  final PaymentMethod paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentEntity({
    this.id,
    required this.invoiceType,
    required this.invoiceId,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, invoiceType, invoiceId, paymentDate, amount, paymentMethod, notes, createdAt, updatedAt];
}
