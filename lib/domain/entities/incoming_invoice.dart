import 'package:equatable/equatable.dart';
import 'enums.dart';

class IncomingInvoiceItemEntity extends Equatable {
  final int? id;
  final int? itemId;
  final String itemNameSnapshot;
  final String unitSnapshot;
  final double priceSnapshot;
  final double vatRateSnapshot;
  final double quantity;
  final double lineSubtotal;
  final double lineVat;
  final double lineTotal;

  const IncomingInvoiceItemEntity({
    this.id,
    this.itemId,
    required this.itemNameSnapshot,
    required this.unitSnapshot,
    required this.priceSnapshot,
    required this.vatRateSnapshot,
    required this.quantity,
    required this.lineSubtotal,
    required this.lineVat,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [id, itemId, itemNameSnapshot, unitSnapshot, priceSnapshot, vatRateSnapshot, quantity, lineSubtotal, lineVat, lineTotal];
}

class IncomingInvoiceEntity extends Equatable {
  final int? id;
  final String invoiceNumber;
  final int supplierId;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final double subtotal;
  final double vatTotal;
  final double total;
  final double paidAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<IncomingInvoiceItemEntity> items;

  const IncomingInvoiceEntity({
    this.id,
    required this.invoiceNumber,
    required this.supplierId,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.subtotal,
    required this.vatTotal,
    required this.total,
    required this.paidAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  double get remainingAmount => (total - paidAmount).clamp(0, double.infinity);

  @override
  List<Object?> get props => [id, invoiceNumber, supplierId, issueDate, dueDate, status, subtotal, vatTotal, total, paidAmount, notes, createdAt, updatedAt, items];
}
