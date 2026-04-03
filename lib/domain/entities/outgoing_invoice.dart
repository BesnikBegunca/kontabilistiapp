import 'package:equatable/equatable.dart';
import 'enums.dart';

class OutgoingInvoiceItemEntity extends Equatable {
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

  const OutgoingInvoiceItemEntity({
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

class OutgoingInvoiceEntity extends Equatable {
  final int? id;
  final String invoiceNumber;
  final int customerId;
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
  final List<OutgoingInvoiceItemEntity> items;

  const OutgoingInvoiceEntity({
    this.id,
    required this.invoiceNumber,
    required this.customerId,
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

  OutgoingInvoiceEntity copyWith({
    int? id,
    String? invoiceNumber,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    double? subtotal,
    double? vatTotal,
    double? total,
    double? paidAmount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OutgoingInvoiceItemEntity>? items,
  }) {
    return OutgoingInvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      vatTotal: vatTotal ?? this.vatTotal,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, invoiceNumber, customerId, issueDate, dueDate, status, subtotal, vatTotal, total, paidAmount, notes, createdAt, updatedAt, items];
}
