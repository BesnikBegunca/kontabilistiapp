import '../../../domain/entities/party_summary.dart';
import '../database/app_database.dart';

class PartySummaryDao {
  Future<List<PartySummary>> getCustomerSummaries({String search = ''}) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT
        c.id,
        c.name,
        c.city,
        c.phone,
        c.email,
        COALESCE(SUM(oi.total), 0) AS total_invoices,
        COALESCE(SUM(oi.paid_amount), 0) AS paid_amount,
        COALESCE(SUM(oi.total - oi.paid_amount), 0) AS remaining_amount,
        COALESCE(COUNT(oi.id), 0) AS invoice_count
      FROM customers c
      LEFT JOIN outgoing_invoices oi ON oi.customer_id = c.id
      WHERE (? = '' OR c.name LIKE ? OR c.email LIKE ? OR c.phone LIKE ?)
      GROUP BY c.id, c.name, c.city, c.phone, c.email
      ORDER BY remaining_amount DESC, c.name ASC
    ''', [search.trim(), '%$search%', '%$search%', '%$search%']);
    return rows.map(_map).toList();
  }

  Future<List<PartySummary>> getSupplierSummaries({String search = ''}) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT
        s.id,
        s.name,
        s.city,
        s.phone,
        s.email,
        COALESCE(SUM(ii.total), 0) AS total_invoices,
        COALESCE(SUM(ii.paid_amount), 0) AS paid_amount,
        COALESCE(SUM(ii.total - ii.paid_amount), 0) AS remaining_amount,
        COALESCE(COUNT(ii.id), 0) AS invoice_count
      FROM suppliers s
      LEFT JOIN incoming_invoices ii ON ii.supplier_id = s.id
      WHERE (? = '' OR s.name LIKE ? OR s.email LIKE ? OR s.phone LIKE ?)
      GROUP BY s.id, s.name, s.city, s.phone, s.email
      ORDER BY remaining_amount DESC, s.name ASC
    ''', [search.trim(), '%$search%', '%$search%', '%$search%']);
    return rows.map(_map).toList();
  }

  PartySummary _map(Map<String, Object?> row) {
    return PartySummary(
      id: row['id'] as int,
      name: row['name'] as String,
      city: row['city'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      totalInvoices: (row['total_invoices'] as num).toDouble(),
      paidAmount: (row['paid_amount'] as num).toDouble(),
      remainingAmount: (row['remaining_amount'] as num).toDouble(),
      invoiceCount: (row['invoice_count'] as num).toInt(),
    );
  }
}
