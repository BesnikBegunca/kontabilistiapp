import 'package:equatable/equatable.dart';

class PartySummary extends Equatable {
  final int id;
  final String name;
  final String? city;
  final String? phone;
  final String? email;
  final double totalInvoices;
  final double paidAmount;
  final double remainingAmount;
  final int invoiceCount;

  const PartySummary({
    required this.id,
    required this.name,
    this.city,
    this.phone,
    this.email,
    required this.totalInvoices,
    required this.paidAmount,
    required this.remainingAmount,
    required this.invoiceCount,
  });

  @override
  List<Object?> get props => [id, name, city, phone, email, totalInvoices, paidAmount, remainingAmount, invoiceCount];
}
