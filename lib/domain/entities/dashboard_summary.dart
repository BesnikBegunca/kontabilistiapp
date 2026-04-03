import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double totalSalesThisMonth;
  final double totalPurchasesThisMonth;
  final double totalExpensesThisMonth;
  final double unpaidOutgoingInvoices;
  final double unpaidIncomingInvoices;
  final double cashBalance;
  final double bankBalance;
  final int overdueOutgoingInvoices;
  final int overdueIncomingInvoices;

  const DashboardSummary({
    required this.totalSalesThisMonth,
    required this.totalPurchasesThisMonth,
    required this.totalExpensesThisMonth,
    required this.unpaidOutgoingInvoices,
    required this.unpaidIncomingInvoices,
    required this.cashBalance,
    required this.bankBalance,
    required this.overdueOutgoingInvoices,
    required this.overdueIncomingInvoices,
  });

  @override
  List<Object?> get props => [
        totalSalesThisMonth,
        totalPurchasesThisMonth,
        totalExpensesThisMonth,
        unpaidOutgoingInvoices,
        unpaidIncomingInvoices,
        cashBalance,
        bankBalance,
        overdueOutgoingInvoices,
        overdueIncomingInvoices,
      ];
}
