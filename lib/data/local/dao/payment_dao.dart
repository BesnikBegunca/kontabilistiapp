import '../../../domain/entities/payment_entity.dart';
import '../../../domain/entities/enums.dart';
import '../database/app_database.dart';

class PaymentDao {
  Future<List<PaymentEntity>> getPayments({String search = ''}) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'payments',
      where: search.trim().isEmpty ? null : '(invoice_type LIKE ? OR notes LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%'],
      orderBy: 'payment_date DESC, id DESC',
    );

    return rows.map((row) => PaymentEntity(
      id: row['id'] as int?,
      invoiceType: row['invoice_type'] as String,
      invoiceId: row['invoice_id'] as int,
      paymentDate: DateTime.parse(row['payment_date'] as String),
      amount: (row['amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == row['payment_method']),
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }
}
