import '../../../domain/entities/dashboard_summary.dart';
import '../database/app_database.dart';

class DashboardDao {
  Future<DashboardSummary> getSummary() async {
    final db = await AppDatabase.instance;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 1).toIso8601String();
    final today = now.toIso8601String();

    Future<double> scalar(String sql, [List<Object?>? args]) async {
      final rows = await db.rawQuery(sql, args);
      return (rows.first.values.first as num?)?.toDouble() ?? 0;
    }

    final totalSales = await scalar(
      "SELECT COALESCE(SUM(total),0) FROM outgoing_invoices WHERE issue_date >= ? AND issue_date < ? AND status != 'cancelled'",
      [start, end],
    );
    final totalPurchases = await scalar(
      "SELECT COALESCE(SUM(total),0) FROM incoming_invoices WHERE issue_date >= ? AND issue_date < ? AND status != 'cancelled'",
      [start, end],
    );
    final totalExpenses = await scalar(
      "SELECT COALESCE(SUM(amount),0) FROM expenses WHERE expense_date >= ? AND expense_date < ?",
      [start, end],
    );
    final unpaidOut = await scalar(
      "SELECT COALESCE(SUM(total - paid_amount),0) FROM outgoing_invoices WHERE status IN ('issued','partiallyPaid')",
    );
    final unpaidIn = await scalar(
      "SELECT COALESCE(SUM(total - paid_amount),0) FROM incoming_invoices WHERE status IN ('issued','partiallyPaid')",
    );
    final cashBalance = await scalar(
      "SELECT COALESCE(SUM(CASE WHEN direction = 'incoming' THEN amount ELSE -amount END),0) FROM cash_transactions",
    );
    final bankBalance = await scalar("""
      SELECT
        COALESCE((SELECT SUM(opening_balance) FROM bank_accounts WHERE is_active = 1), 0) +
        COALESCE((SELECT SUM(CASE WHEN direction = 'incoming' THEN amount ELSE -amount END) FROM bank_transactions), 0)
    """);
    final overdueOutRows = await db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM outgoing_invoices WHERE due_date < ? AND status IN ('issued','partiallyPaid')",
      [today],
    );
    final overdueInRows = await db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM incoming_invoices WHERE due_date < ? AND status IN ('issued','partiallyPaid')",
      [today],
    );

    return DashboardSummary(
      totalSalesThisMonth: totalSales,
      totalPurchasesThisMonth: totalPurchases,
      totalExpensesThisMonth: totalExpenses,
      unpaidOutgoingInvoices: unpaidOut,
      unpaidIncomingInvoices: unpaidIn,
      cashBalance: cashBalance,
      bankBalance: bankBalance,
      overdueOutgoingInvoices: ((overdueOutRows.first['cnt'] as num?) ?? 0).toInt(),
      overdueIncomingInvoices: ((overdueInRows.first['cnt'] as num?) ?? 0).toInt(),
    );
  }
}
