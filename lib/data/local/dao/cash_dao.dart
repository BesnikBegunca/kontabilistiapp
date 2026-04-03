import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/cash_transaction_entity.dart';
import '../../../domain/entities/enums.dart';
import '../database/app_database.dart';

class CashDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<CashTransactionEntity>> getTransactions({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'cash_transactions',
      where: search.trim().isEmpty ? null : '(reference_no LIKE ? OR description LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%'],
      orderBy: 'transaction_date DESC, id DESC',
    );
    return rows.map((row) => CashTransactionEntity(
      id: row['id'] as int?,
      referenceNo: row['reference_no'] as String?,
      direction: TransactionDirection.values.firstWhere((e) => e.name == row['direction']),
      amount: (row['amount'] as num).toDouble(),
      description: row['description'] as String?,
      transactionDate: DateTime.parse(row['transaction_date'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }

  Future<void> saveTransaction(CashTransactionEntity transaction) async {
    final db = await _db;
    final payload = {
      'reference_no': transaction.referenceNo,
      'direction': transaction.direction.name,
      'amount': transaction.amount,
      'description': transaction.description,
      'transaction_date': transaction.transactionDate.toIso8601String(),
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
    };
    if (transaction.id == null) {
      await db.insert('cash_transactions', payload);
    } else {
      await db.update('cash_transactions', payload, where: 'id = ?', whereArgs: [transaction.id]);
    }
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _db;
    await db.delete('cash_transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getBalance() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN direction = "incoming" THEN amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN direction = "outgoing" THEN amount ELSE 0 END), 0) AS balance
      FROM cash_transactions
    ''');
    return (rows.first['balance'] as num?)?.toDouble() ?? 0;
  }
}
