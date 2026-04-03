import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../domain/entities/bank_entities.dart';
import '../../../domain/entities/enums.dart';
import '../database/app_database.dart';

class BankDao {
  Future<Database> get _db async => AppDatabase.instance;

  Future<List<BankAccountEntity>> getAccounts() async {
    final db = await _db;
    final rows = await db.query('bank_accounts', orderBy: 'name ASC');
    return rows.map((row) => BankAccountEntity(
      id: row['id'] as int?,
      name: row['name'] as String,
      iban: row['iban'] as String?,
      bankName: row['bank_name'] as String?,
      currency: row['currency'] as String,
      openingBalance: (row['opening_balance'] as num).toDouble(),
      isActive: (row['is_active'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }

  Future<void> saveAccount(BankAccountEntity account) async {
    final db = await _db;
    final payload = {
      'name': account.name,
      'iban': account.iban,
      'bank_name': account.bankName,
      'currency': account.currency,
      'opening_balance': account.openingBalance,
      'is_active': account.isActive ? 1 : 0,
      'created_at': account.createdAt.toIso8601String(),
      'updated_at': account.updatedAt.toIso8601String(),
    };
    if (account.id == null) {
      await db.insert('bank_accounts', payload);
    } else {
      await db.update('bank_accounts', payload, where: 'id = ?', whereArgs: [account.id]);
    }
  }

  Future<void> deleteAccount(int id) async {
    final db = await _db;
    await db.delete('bank_accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BankTransactionEntity>> getTransactions({String search = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'bank_transactions',
      where: search.trim().isEmpty ? null : '(reference_no LIKE ? OR description LIKE ?)',
      whereArgs: search.trim().isEmpty ? null : ['%$search%', '%$search%'],
      orderBy: 'transaction_date DESC, id DESC',
    );
    return rows.map((row) => BankTransactionEntity(
      id: row['id'] as int?,
      bankAccountId: row['bank_account_id'] as int,
      referenceNo: row['reference_no'] as String?,
      direction: TransactionDirection.values.firstWhere((e) => e.name == row['direction']),
      amount: (row['amount'] as num).toDouble(),
      description: row['description'] as String?,
      transactionDate: DateTime.parse(row['transaction_date'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    )).toList();
  }

  Future<void> saveTransaction(BankTransactionEntity transaction) async {
    final db = await _db;
    final payload = {
      'bank_account_id': transaction.bankAccountId,
      'reference_no': transaction.referenceNo,
      'direction': transaction.direction.name,
      'amount': transaction.amount,
      'description': transaction.description,
      'transaction_date': transaction.transactionDate.toIso8601String(),
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
    };
    if (transaction.id == null) {
      await db.insert('bank_transactions', payload);
    } else {
      await db.update('bank_transactions', payload, where: 'id = ?', whereArgs: [transaction.id]);
    }
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _db;
    await db.delete('bank_transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getBalance() async {
    final db = await _db;
    final rows = await db.rawQuery("""
      SELECT
        COALESCE((SELECT SUM(opening_balance) FROM bank_accounts WHERE is_active = 1), 0) +
        COALESCE((SELECT SUM(CASE WHEN direction = 'incoming' THEN amount ELSE -amount END) FROM bank_transactions), 0)
        AS balance
    """);
    return (rows.first['balance'] as num?)?.toDouble() ?? 0;
  }
}
